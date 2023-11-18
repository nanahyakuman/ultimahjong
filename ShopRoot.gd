extends Control

var money = 0

var MONEY_PER_ROUND = 10

enum {STATE_ANIMATING, STATE_ACTIVE}
var state

@onready var root = $"../../.."
@onready var cash_label = $"../GUIManager/TableTop/HBoxContainer/CashLabel"
@onready var to_be_started = [
	$VBoxContainer/AkaPurchaseables,
	$VBoxContainer/TilePurchaseables,
	$VBoxContainer/HBoxContainer/DeadWallPurchaseables,
	$VBoxContainer/HBoxContainer/KanRevealPurchaseables,
]

func start():
	state = STATE_ACTIVE
	
	adjust_money(MONEY_PER_ROUND)
	
	MusicManager.start_shop()
	
	for s in to_be_started:
		s.start()


func adjust_money(amount: int):
	money += amount
	cash_label.text = "[b]$%s " % str(money)
	

func close():
	MusicManager.stop_music()
	root.start_round()
