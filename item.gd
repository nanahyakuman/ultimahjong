extends Control
class_name Item

@onready var counter_label = $PanelContainer/CounterLabel
@onready var sprite_2d = $Sprite2D
@onready var panel_container = $PanelContainer
@onready var description = $Description
@onready var hover_name = $Description/VBoxContainer/PanelContainer/HBoxContainer/PanelContainer/Name
@onready var hover_text = $Description/VBoxContainer/Label
var mahjong_manager
var tile_select

enum TYPES {NONE, ERASER, WIND_MAGNET, BATTERY, KAN_SWAP, PIN_DUPE, SOU_ADJ}
@export var type = TYPES.NONE
var cooldown_counter

# rememvers selected tiles, for example if necessary to select two tiles
var selected_tile_memory = []

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
		TYPES.PIN_DUPE:
			hover_name.text = "Pinplicator"
			hover_text.text = "Convert a selected Pin into a selected Pin (temporarily)."
		TYPES.SOU_ADJ:
			hover_name.text = "Sou-so"
			hover_text.text = "Convert a selected Sou into a selected Sou's predecessor (temporarily)."
	
	cooldown_counter = 0
	sprite_2d.frame_coords.x = type
	
	mahjong_manager = %MahjongManager
	tile_select = %TileSelect

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
			tile_select.update_text("Select a tile to swap in.")
			
			cooldown_counter = 80
		
		TYPES.PIN_DUPE:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a Pin to be swapped.")
			
			cooldown_counter = 52
		
		TYPES.SOU_ADJ:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a Sou to be swapped.")
			
			cooldown_counter = 52
	
	assert(cooldown_counter > 0, "you forgot to reassign the cooldown counter!!")
	cooldown_counter += 1
	decrement()


#  simple checker called by `MahjongManager to ask if a tile is valid. pindupe
# for example only accepts pins. 
#  default behavior is to return TRUE!
func tile_valid(tile: MTile):
	match type:
		TYPES.PIN_DUPE:
			if tile.suit != MTile.SUITS.PIN:
				return false
		TYPES.SOU_ADJ:
			if tile.suit != MTile.SUITS.SOU:
				return false
	
	return true


#  some items require an item to be selected. we take advantage of `MahjongManager`'s
# existing code to prompt selection, then do with it what we will down here.
func tile_selected(tile: MTile):
	match type:
		TYPES.KAN_SWAP:
			var t = mahjong_manager.get_and_overwrite_most_recent_kan_dora(tile)
			mahjong_manager.add_to_hand_and_update(t)
			
		TYPES.PIN_DUPE:
			#  we dont actually even use the stored tile, lol. just an easy way to
			# make a check. note that the PIN-type assurance is made in `tile_valid`.
			if selected_tile_memory.size() == 0:
				selected_tile_memory.append(tile)
				
				# override default update behavior to get two items
				mahjong_manager.complete_tile_select()
				mahjong_manager.request_tile_select(self, false)
				tile_select.update_text("Select a Pin to become.")
				return
			else:
				mahjong_manager.add_to_hand_and_update(tile)
				selected_tile_memory.clear()
		
		TYPES.SOU_ADJ:
			if selected_tile_memory.size() == 0:
				selected_tile_memory.append(tile)
				
				# override default update behavior to get two items
				mahjong_manager.complete_tile_select()
				mahjong_manager.request_tile_select(self, false)
				tile_select.update_text("Select a Sou to predecess.")
				return
			else:
				var val = tile.value
				val -= 1
				if val <= 0:
					val = 9
				mahjong_manager.add_to_hand_and_update(MTile.new(MTile.SUITS.SOU, val))
				selected_tile_memory.clear()
	
	mahjong_manager.complete_tile_select()
	tile_select.update_text("")



func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_use()

func _mouse_entered():
	description.visible = true
func _mouse_exited():
	description.visible = false
