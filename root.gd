extends Control

@onready var mahjong_manager = %MahjongManager
@onready var shop_root = $HBoxContainer/MahjongRoot/ShopRoot
@onready var score_label = $HBoxContainer/MahjongRoot/GUIManager/TableTop/HBoxContainer/ScoreLabel
@onready var scoring_root = $HBoxContainer/MahjongRoot/ScoringRoot

var score = 0.0

func _ready():
	await get_tree().process_frame
	
	start_round()
	
	await get_tree().process_frame
	start_scoring()
#	end_round(42, 2)

func start_round():
	shop_root.visible = false
	scoring_root.visible = false
	mahjong_manager.start_round()

func end_round(fu: int, han: int):
	var points = int(fu * pow(2.0, han + 2.0))
	points = ceili(points / 10.0) * 10
	score += points
	
	score_label.clear()
	score_label.append_text("[b]" + str(score))
	
	# temp probably
	TileGraphicKnower.update_dora_ids([])
	
	start_scoring()

func start_scoring():
	shop_root.visible = false
	scoring_root.visible = true

func start_shop():
	scoring_root.visible = false
	shop_root.visible = true
	shop_root.start()
	
