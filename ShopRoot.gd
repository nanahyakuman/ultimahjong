extends Control

var money = 0

const LOSE_ALL_MONEY = true

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
@onready var colored_purchaseables_2 = $VBoxContainer/ColoredPurchaseables2
@onready var really_close_catcher = $ReallyCloseCatcher
@onready var color_rect = $ColorRect
@onready var everything_container = $VBoxContainer


func start(was_victory: bool):
	state = STATE_ACTIVE
	
	really_close_catcher.visible = false
	
	
	everything_container.visible = false
	var increment = 16
	color_rect.size.y = increment
	for i in range(0, size.y, increment):
		color_rect.size.y = i
		await AnimTimer.start_mod(.05)
	color_rect.size.y = size.y
	
	# money is added elsewhere
	MusicManager.start_shop()
	
	for s in to_be_started:
		s.start()
	
	colored_purchaseables_2.start()
	
	# prevent glitching in
	await get_tree().process_frame
	everything_container.visible = true

func adjust_money(amount: int):
	money += amount
	cash_label.text = "[b]%s¥ " % str(money)


#  prompt the player that they're gonna lose all their money if 
# applicable
func try_close():
	if !LOSE_ALL_MONEY:
		close()
	else:
		if money > 0:
			really_close_catcher.visible = true
		else:
			close()

func close():
	if LOSE_ALL_MONEY:
		adjust_money(-money)
	MusicManager.stop_music()
	root.start_round()


func load_cfg(config: ConfigFile):
	money = config.get_value("shop", "money")
	adjust_money(0)
	
func save_cfg(config: ConfigFile):
	config.set_value("shop", "money", money)
