extends Control

@onready var mahjong_manager = %MahjongManager
@onready var shop_root = %ShopRoot
@onready var scoring_root = %ScoringRoot
@onready var score_tracker = $ScoreTracker

# gets incremented once we start
var round_counter = -1

# this is temp
func _ready():
	await get_tree().process_frame
	
	var character_info = CharacterInfo.new()
	character_info.set_type(CharacterInfo.TYPES.SANMA)
	
	start_game(character_info)

func start_game(character_info: CharacterInfo):
	mahjong_manager.initialize(character_info)
	score_tracker.initialize(character_info)
	start_round()


func start_round():
	shop_root.visible = false
	scoring_root.visible = false
	mahjong_manager.start_round()
	round_counter += 1
	
	# give player live updates on expectations
	score_tracker.add_future_score()

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

func start_shop():
	TileGraphicKnower.update_dora_ids([])
	
	scoring_root.visible = false
	shop_root.visible = true
	shop_root.start()
	
	# raise the threshhold
	score_tracker.increment_counters()
