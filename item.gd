extends Control
class_name Item

@onready var counter_label = $PanelContainer/CounterLabel
@onready var sprite_2d = $Sprite2D
@onready var panel_container = $PanelContainer
@onready var description = $Description
@onready var hover_name = $Description/VBoxContainer/PanelContainer/HBoxContainer/PanelContainer/Name
@onready var hover_text = $Description/VBoxContainer/Label
var mahjong_manager

enum TYPES {NONE, ERASER, WIND_MAGNET, BATTERY, KAN_SWAP}
@export var type = TYPES.NONE
var cooldown_counter

func _ready():
	connect("mouse_entered", _mouse_entered)
	connect("mouse_exited", _mouse_exited)
	_mouse_exited()
	
	# hovertexting
	match type:
		TYPES.ERASER:
			hover_name.text = "Eraser"
			hover_text.text = "Current tsumo tile becomes a White Dragon (temporarily)."
		TYPES.WIND_MAGNET:
			hover_name.text = "Wind Charm"
			hover_text.text = "4th tile in the wall switches positions with a random wind from the remaining wall, if there is one."
		TYPES.BATTERY:
			hover_name.text = "9-Volt"
			hover_text.text = "Reduce all other item's cooldown counters by 9."
		TYPES.KAN_SWAP:
			hover_name.text = "Kan Swap"
			hover_text.text = "Replace the most recently revealed kan dora with a tile from hand."
	
	cooldown_counter = 0
	sprite_2d.frame_coords.x = type
	
	mahjong_manager = %MahjongManager
	
	decrement()

func decrement(amount: int = 1):
	cooldown_counter -= amount
	panel_container.visible = cooldown_counter > 0
	counter_label.text = str(maxi(0,cooldown_counter))
	sprite_2d.frame_coords.y = 0 if cooldown_counter <= 0 else 1

func _use():
	if cooldown_counter > 0:
		return
	if mahjong_manager:
		if mahjong_manager._state != MahjongManager.STATE_ACTIONABLE:
			return
	
	match type:
		TYPES.NONE:
			#actual code here
			cooldown_counter = 9999
		TYPES.ERASER:
			if mahjong_manager.tsumo:
				mahjong_manager.do_tsumo(MTile.new(MTile.SUITS.SPECIAL,MTile.SPECIALS.HAKU))
			else:
				return
			cooldown_counter = 48
			
		TYPES.WIND_MAGNET:
			var winds = []
			for i in range(mahjong_manager.wall.size()-1,-1,-1):
				var t = mahjong_manager.wall[i]
				if t.suit == MTile.SUITS.SPECIAL:
					if MTile.WINDS.has(t.value):
						winds.append(t)
			
			#  select a random wind tile from the deck and swap it
			# for the next draw from the deck
			if winds.size() != 0:
				var index = randi()%winds.size()
				var wind = winds[index]
				var find = mahjong_manager.wall.find(wind)
				
				#  swap selected wind with next tsumo, preventing us from reshuffling
				# the whole deck
				var switch = mahjong_manager.wall[-mahjong_manager.upgrades.get_discard_count()-1]
				mahjong_manager.wall[-mahjong_manager.upgrades.get_discard_count()-1] = wind
				mahjong_manager.wall[find] = switch
			
			cooldown_counter = 16
			
		TYPES.BATTERY:
			for m in get_parent().get_children():
				m.decrement(9)
			
			cooldown_counter = 24
			
		TYPES.KAN_SWAP:
			mahjong_manager.request_tile_select(self, true)
			
			cooldown_counter = 80
	
	assert(cooldown_counter > 0, "you forgot to reassign the cooldown counter!!")
	cooldown_counter += 1
	decrement()


#  some items require an item to be selected. we take advantage of `MahjongManager`'s
# existing code to prompt selection, then do with it what we will down here.
func tile_selected(tile: MTile):
	match type:
		TYPES.KAN_SWAP:
			var t = mahjong_manager.get_and_overwrite_most_recent_kan_dora(tile)
			mahjong_manager.add_to_hand_and_update(t)
			
	
	mahjong_manager.complete_tile_select()



func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_use()

func _mouse_entered():
	description.visible = true
func _mouse_exited():
	description.visible = false
