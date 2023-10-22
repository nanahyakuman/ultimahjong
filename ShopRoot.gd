extends Control

var money = 0

var MONEY_PER_ROUND = 10

@onready var root = $"../../.."
@onready var cash_label = $"../GUIManager/TableTop/HBoxContainer/CashLabel"
@onready var to_be_started = [
	$VBoxContainer/AkaPurchaseables,
	$VBoxContainer/TilePurchaseables
]

func start():
	adjust_money(MONEY_PER_ROUND)
	
	for s in to_be_started:
		s.start()


func adjust_money(amount: int):
	money += amount
	cash_label.text = "[b]$%s " % str(money)
	

func close():
	root.start_round()
