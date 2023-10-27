extends Control

@onready var mahjong_manager = %MahjongManager
@onready var shop_root = $HBoxContainer/MahjongRoot/ShopRoot
@onready var score_label = $HBoxContainer/MahjongRoot/GUIManager/TableTop/HBoxContainer/ScoreLabel
@onready var scoring_root = $HBoxContainer/MahjongRoot/ScoringRoot

var score = 0.0

func _ready():
	await get_tree().process_frame
	
	start_round()
	
	await get_tree().create_timer(2.0).timeout
	end_round(ScoringInfo.new(), 6)

func start_round():
	shop_root.visible = false
	scoring_root.visible = false
	mahjong_manager.start_round()

# also start scoring
func end_round(scoring_info: ScoringInfo, multiplier: int):
	shop_root.visible = false
	scoring_root.visible = true
	
	var fu = scoring_info.get_total_fu()
	var han = scoring_info.get_total_han()
	
	var points = int(fu * pow(2.0, han + 2.0))
	points = ceili(points / 10.0) * 10
	points *= multiplier
	
	# 0 points for exhaustive
	if han == 0:
		points = 0
	
	score += points
	
	scoring_root.update_scoring(scoring_info, fu, han, points, multiplier)
	
	score_label.clear()
	score_label.append_text("[b]" + str(score))


func start_shop():
	TileGraphicKnower.update_dora_ids([])
	
	scoring_root.visible = false
	shop_root.visible = true
	shop_root.start()
	
