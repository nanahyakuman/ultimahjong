extends Control

var money = 0

var MONEY_PER_ROUND = 3

enum {STATE_ANIMATING, STATE_ACTIVE}
var state

@onready var root = $"../../.."
@onready var cash_label = $"../GUIManager/TableTop/HBoxContainer/CashLabel"
@onready var to_be_started = [
	# these are given as rewards for a successful round
	#$VBoxContainer/ColoredPurchaseables,
	# no longer selling these, don't liek how it messes up counts
	#$VBoxContainer/TilePurchaseables,
	$VBoxContainer/UpgradePurchaseables,
	$VBoxContainer/ItemPurchaseables
]
@onready var colored_purchaseables = $VBoxContainer/ColoredPurchaseables
@onready var dora_info_label = $VBoxContainer/DoraInfoLabel

func start(was_victory: bool):
	state = STATE_ACTIVE
	
	adjust_money(MONEY_PER_ROUND)
	
	MusicManager.start_shop()
	
	for s in to_be_started:
		s.start()
	
	if was_victory:
		colored_purchaseables.start()
		dora_info_label.text = "[center]" + tr("SHOP_DORA_DESC_W")
		dora_info_label.visible = true
	else:
		colored_purchaseables.visible = false
		#dora_info_label.text = "[center]" + tr("SHOP_DORA_DESC_L")
		dora_info_label.visible = false

func adjust_money(amount: int):
	money += amount
	cash_label.text = "[b]%s¥ " % str(money)
	

func close():
	adjust_money(-money)
	MusicManager.stop_music()
	root.start_round()
