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
var popup_tile_select
var mana_bar


#  diffrent item ids.
enum TYPES {NONE, ERASER, WIND_MAGNET, BATTERY, KAN_SWAP, PIN_DUPE, SOU_ADJ, AKAFY, POCCHI, MAN_TERM, DRAGON_CYCLE, SUJI_OFFSET}
#  items either use mana, charge themselves, or are one-time use
@export var type: TYPES = TYPES.NONE
const COOLD = [0,     48,          15,      24,       70,       44,      52,    61,     59,       36,           31,          32]

enum {ONCE, MANA, TIMR}
# make sure to set BEFORE calling _ready()!
@export var charge_type = TIMR
#  only used if the charge type is TIMR, tracks cooldown
var cooldown_counter = 0

# link self up if already added to tree. debug and reload use
@export var activate_self = false

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
			hover_text.text = "Current tsumo tile is replaced with a White Dragon (temporarily)."
		TYPES.WIND_MAGNET:
			hover_name.text = "Wind Charm"
			hover_text.text = "4th tile in the wall switches positions with a random wind from the remaining wall, if there is one."
		TYPES.BATTERY:
			hover_name.text = "9-Volt"
			hover_text.text = "Reduce all other item's cooldown counters by 9."
		TYPES.KAN_SWAP:
			hover_name.text = "Kan Swap"
			hover_text.text = "Replace the most recently revealed kan dora with a tile from hand or tsumo."
		TYPES.PIN_DUPE:
			hover_name.text = "Pinplicator"
			hover_text.text = "Convert a selected Pin into a selected Pin (temporarily)."
		TYPES.SOU_ADJ:
			hover_name.text = "Sou-so"
			hover_text.text = "Convert a selected Sou into a selected Sou's predecessor (temporarily)."
		TYPES.AKAFY:
			hover_name.text = "Factory Seize"
			hover_text.text = "A random non-aka tile in hand (not tsumo) becomes aka."
		TYPES.POCCHI:
			hover_name.text = "A·Rock"
			hover_text.text = "Add a Pocchi to the current tsumo tile (permanently)."
		TYPES.MAN_TERM:
			hover_name.text = "Hat Man"
			hover_text.text = "Shift a selected Man's value into the terminal further from it (temporarily). Distance ties are chosen at random."
		TYPES.DRAGON_CYCLE:
			hover_name.text = "Dragon Cycle"
			hover_text.text = "Change a selected Dragon's color (W>G>R>W)."
		TYPES.SUJI_OFFSET:
			hover_name.text = "Suji Shift"
			hover_text.text = "Adjust current tsumo tile's value by +/- 3. Only works on numbered tiles."
	
	# additional gfx that vary based on type
	match charge_type:
		ONCE:
			hover_text.text += "\nOne-time use."
			panel_container.get_theme_stylebox("panel").region_rect.position.x = 8 * 3
		MANA:
			hover_text.text += "\nConsumes %d Mana." % COOLD[type]
			panel_container.get_theme_stylebox("panel").region_rect.position.x = 8 * 1
		TIMR:
			hover_text.text += "\nCooldown of %d." % COOLD[type]
			panel_container.get_theme_stylebox("panel").region_rect.position.x = 8 * 2
	
	
	sprite_2d.frame_coords.x = type % sprite_2d.hframes
	update_graphics(9999)
	
	if activate_self:
		activate(%MahjongManager, %TileSelectPanel, %PopupTileSelector, %ManaBar)
	
	panel_container.visible = true
	counter_label.text = str(COOLD[type])
	if charge_type == ONCE:
		counter_label.text = str(1)
	#decrement()

#  called after purchase, not when added to a purchaseable. also called by self
# on `_ready()` if appropriate.
func activate(mm: MahjongManager, ts: Node, pts: Node, mb: Node):
	# the parent exists in the same scene as these
	mahjong_manager = mm
	tile_select = ts
	popup_tile_select = pts
	mana_bar = mb
	
	update_graphics(mb.mana)


func _use():
	# determine if can use atm.
	match charge_type:
		ONCE:
			pass
		MANA:
			if !mana_bar:
				return
			if !mana_bar.can_use_mana(COOLD[type]):
				return
		TIMR:
			if cooldown_counter > 0:
				return
	
	
	# not activated yet check
	if !mahjong_manager:
		return
	if mahjong_manager._state != MahjongManager.STATE_ACTIONABLE:
		return
	
	match type:
		TYPES.NONE:
			#actual code here
			pass
		
		TYPES.ERASER:
			# old tile is cleared completely, dont maintain reference
			mahjong_manager.tsumo = null
			mahjong_manager.do_tsumo(MTile.new(MTile.SUITS.SPECIAL,MTile.SPECIALS.HAKU))
			
		TYPES.WIND_MAGNET:
			var wind_ids = []
			for w in MTile.WINDS:
				wind_ids.append(MTile.gen_id(MTile.SUITS.SPECIAL, w))
			
			mahjong_manager.swap_in_next_theoretical_tsumo(wind_ids)
			
		TYPES.BATTERY:
			#mana_bar.add_mana(1)
			print("does nothing lol")
			
		TYPES.KAN_SWAP:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a tile to swap in.")
			return # more steps to follow so we skip over updating the counter
			
		TYPES.PIN_DUPE:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a Pin to be swapped.")
			return
			
		TYPES.SOU_ADJ:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a Sou to be swapped.")
			return
			
		TYPES.AKAFY:
			#  start at a random index and iterate until finmding a
			# non-aka tile
			var i = randi() % mahjong_manager.hand.size()
			var ii = i
			while true:
				ii += 1
				ii %= mahjong_manager.hand.size()
				if mahjong_manager.hand[ii].color == MTile.COL_NONE:
					mahjong_manager.hand[ii].color = MTile.COL_AKA
					mahjong_manager.update_hand_label()
					break
				# excape case for all aka
				if i == ii:
					break
		
		TYPES.POCCHI:
			mahjong_manager.tsumo.pocchi = true
			# it's permananent
			mahjong_manager.tsumo.canon_tile.pocchi = true
			# queue side panel redraw
			mahjong_manager.tile_counter.emit_signal("updated")
			mahjong_manager.gui_manager.update_tsumo([mahjong_manager.tsumo])
			
		
		TYPES.MAN_TERM:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a Man to be swapped.")
			return
		
		TYPES.DRAGON_CYCLE:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a Dragon to cycle.")
			return
		
		TYPES.SUJI_OFFSET:
			mahjong_manager.stall_for_external_select()
			
			var tsumo = mahjong_manager.tsumo
			
			if !MTile.NUMERALS.has(tsumo.suit):
				return
			
			var tile_vals = [tsumo.value-3, tsumo.value+3]
			var new_tiles = []
			for i in tile_vals:
				if i <= 0:
					i += 9
				if i >= 10:
					i -= 9
				new_tiles.append(MTile.new(tsumo.suit, i))
			
			new_tiles.sort_custom(Callable(MTile, "tile_compare"))
			
			popup_tile_select.set_tiles(new_tiles)
			popup_tile_select.request_tile_select(self)
			tile_select.update_text("Select a new value.")
			
	
	#  default item behaviour assumes the usage is immediate, if not
	# call return in switch above.
	_expend_resource()


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
		TYPES.MAN_TERM:
			if tile.suit != MTile.SUITS.MAN:
				return false
		TYPES.DRAGON_CYCLE:
			if tile.suit != MTile.SUITS.SPECIAL or !MTile.BASIC_DRAGONS.has(tile.value):
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
				var new_t = selected_tile_memory[0].duplicate()
				new_t.value = tile.value
				new_t.former = tile
				mahjong_manager.add_to_hand_and_update(new_t)
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
				
				var new_t = selected_tile_memory[0].duplicate()
				new_t.value = val
				new_t.former = tile
				
				mahjong_manager.add_to_hand_and_update(new_t)
				selected_tile_memory.clear()
		
		TYPES.MAN_TERM:
			var new_tile = tile.duplicate()
			new_tile.value = 1 if randi()%1 else 9
			
			if tile.value < 5:
				new_tile.value = 9
			elif tile.value > 5:
				new_tile.value = 1
			
			new_tile.former = tile
			
			mahjong_manager.add_to_hand_and_update(new_tile)
		
		TYPES.DRAGON_CYCLE:
			var val
			match tile.value:
				MTile.SPECIALS.HAKU:
					val = MTile.SPECIALS.HATSU
				MTile.SPECIALS.HATSU:
					val = MTile.SPECIALS.CHUN
				MTile.SPECIALS.CHUN:
					val = MTile.SPECIALS.HAKU
			var new_tile = tile.duplicate()
			new_tile.former = tile
			new_tile.value = val
			mahjong_manager.add_to_hand_and_update(new_tile)
		
		TYPES.SUJI_OFFSET:
			var new_tile = mahjong_manager.tsumo.duplicate()
			new_tile.value = tile.value
			new_tile.former = mahjong_manager.tsumo
			mahjong_manager.tsumo = null
			mahjong_manager.add_to_hand_and_update(new_tile)
	
	# default completion behaviour
	mahjong_manager.complete_tile_select()
	popup_tile_select.set_tiles([])
	tile_select.update_text("")
	_expend_resource()

# update the counter.
func update_graphics(val: int):
	match charge_type:
		ONCE:
			pass
		MANA:
			sprite_2d.frame_coords.y = type / (sprite_2d.hframes) * 2 + int(COOLD[type] > val)
		TIMR:
			panel_container.visible = cooldown_counter > 0
			counter_label.text = str(maxi(0,cooldown_counter))
			sprite_2d.frame_coords.y = type / (sprite_2d.hframes) * 2 + int(cooldown_counter > 0)
			sprite_2d.frame_coords.y = type / (sprite_2d.hframes) * 2 + int(cooldown_counter > 0)

# called on item use, spends mana/cooldown/the item as appropriate.
func _expend_resource():
	match charge_type:
		ONCE:
			queue_free()
		MANA:
			mana_bar.use_mana(COOLD[type])
			get_parent().update_tile_graphics()
		TIMR:
			cooldown_counter = COOLD[type]
			decrement(0)
			

func decrement(amount: int = 1):
	if charge_type != TIMR:
		return
	cooldown_counter -= amount
	#  this is only called if CHARGE_TYPE == TIMR. it follows that
	# we dotn care about the mana so '-1' as the arg is fine.
	update_graphics(-1)


# called from `MahjongManager` to hack into same code as cancelling a call.
func cancel_selection():
	tile_select.update_text("")
	selected_tile_memory.clear()


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_use()

func _mouse_entered():
	description.visible = true
func _mouse_exited():
	description.visible = false
