extends Control

@onready var mahjong_manager = %MahjongManager
@onready var shop_root = $HBoxContainer/MahjongRoot/ShopRoot
@onready var score_label = $HBoxContainer/MahjongRoot/GUIManager/All/TextureRect/HBoxContainer/ScoreLabel

var score = 0.0

func _ready():
	await get_tree().process_frame
	
	start_round()
	
	await get_tree().process_frame
	end_round(30, 2)

func start_round():
	shop_root.visible = false
	mahjong_manager.start_round()

func end_round(fu: int, han: int):
	han = 1
	var points = fu * pow(2.0, han + 1.0)
	points = ceil(points / 100.0) * 100.0
	score += points * 5
	
	score_label.text = "[b]" + str(score)
	
	# temp probably
	TileGraphicKnower.update_dora_ids([])
	
	start_shop()

func start_shop():
	shop_root.visible = true
	shop_root.start()
	
