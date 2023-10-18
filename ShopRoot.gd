extends Control

var money = 0

var MONEY_PER_ROUND = 5

@onready var root = $"../../.."
@onready var cash_label = $"../GUIManager/All/TextureRect/HBoxContainer/CashLabel"
@onready var aka_purchaseables = $VBoxContainer/AkaPurchaseables

func start():
	adjust_money(MONEY_PER_ROUND)
	
	aka_purchaseables.start()


func adjust_money(amount: int):
	money += amount
	cash_label.text = "[b]$%s " % str(money)
	

func close():
	root.start_round()
