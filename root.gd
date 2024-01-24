extends Control

@onready var mahjong_manager = %MahjongManager
@onready var shop_root = %ShopRoot
@onready var scoring_root = %ScoringRoot
@onready var score_tracker = $ScoreTracker
@onready var state_saver = $StateSaver
@onready var upgrades = $HBoxContainer/MahjongRoot/MahjongManager/Upgrades

# gets incremented once we start.
# also accessed by mahjmanager
var round_counter = -1
#  so the shop knows whether to give you free dora or not
var last_round_was_victory = false

# mostly used on save/load
enum {STATE_ROUND, STATE_SHOP}
var state = STATE_ROUND

func _ready():
	await get_tree().process_frame
	
	start_game()

func start_game():
	#  this procs individual node's loading code before any
	# init code!
	if CharInfoForwarder.load:
		state_saver.load_cfg()
	
	#  nodes should do their actual loading in their respective `save_cfg()` calls,
	# passing bool `load` through should only be used to disable normal init code that would
	# conflict, not trigger any loading itself.
	mahjong_manager.initialize(CharInfoForwarder.ci, CharInfoForwarder.load)
	score_tracker.initialize(CharInfoForwarder.ci, CharInfoForwarder.load)
	if state == STATE_ROUND:
		start_round()
	else:
		start_shop(CharInfoForwarder.load)


func start_round():
	round_counter += 1
	shop_root.visible = false
	scoring_root.visible = false
	mahjong_manager.start_round()
	
	# give player live updates on expectations
	score_tracker.add_future_score()
	
	state = STATE_ROUND

# also start scoring
func end_round(scoring_info: ScoringInfo, multiplier_info: MultiplierInfo):
	shop_root.visible = false
	scoring_root.visible = true
	
	var fu = scoring_info.get_total_fu()
	var han = scoring_info.get_total_han()
	
	var points = scoring_info.get_base_points()
	points = multiplier_info.get_multiplied(points)
	
	# 0 points for exhaustive
	if han == 0:
		points = 0
	
	await scoring_root.update_scoring(scoring_info, fu, han, points, multiplier_info.get_multiplier())
	
	# add points and check we beat the threshhold
	score_tracker.update_score(points)
	
	# update early so you can't quit to retry a round
	state = STATE_SHOP
	shop_root.adjust_money(upgrades.get_money_per_round())
	
	# tracker for shop
	last_round_was_victory = points > 0

func start_shop(was_load: bool = false):
	TileGraphicKnower.update_dora_ids([])
	
	scoring_root.visible = false
	shop_root.visible = true
	shop_root.start(last_round_was_victory)
	
	# raise the threshhold
	if !was_load:
		score_tracker.increment_counters()


#overwrite global charinfo
func load_cfg(config: ConfigFile):
	CharInfoForwarder.ci.set_type(config.get_value("state", "CharInfoType"))
	state = config.get_value("state", "root_state", STATE_ROUND)
	# reincremented when a round is started
	round_counter = config.get_value("state", "round_counter", round_counter)-1
	last_round_was_victory = config.get_value("state", "last_round_was_victory", false)
func save_cfg(config: ConfigFile):
	config.set_value("state", "CharInfoType", CharInfoForwarder.ci.type)
	config.set_value("state", "root_state", state)
	config.set_value("state", "round_counter", round_counter)
	config.set_value("state", "last_round_was_victory", last_round_was_victory)
	
