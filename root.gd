extends Control

@onready var mahjong_manager = %MahjongManager
@onready var shop_root = %ShopRoot
@onready var scoring_root = %ScoringRoot
@onready var score_tracker = $ScoreTracker

var character_info = CharacterInfo.new()

var round_counter = 0

func _ready():
	await get_tree().process_frame
	
	character_info.set_type(character_info.REGULAR)
	
	mahjong_manager.initialize(character_info)
	score_tracker.initialize(character_info)
	start_round()
	
#	await get_tree().create_timer(2.0).timeout
#	end_round(ScoringInfo.new(), 6)

func start_round():
	shop_root.visible = false
	scoring_root.visible = false
	mahjong_manager.start_round()

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
