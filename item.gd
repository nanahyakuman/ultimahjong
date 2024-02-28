extends Control
class_name Item

@onready var counter_label = $PanelContainer/CounterLabel
@onready var sprite_2d = $Sprite2D
@onready var panel_container = $PanelContainer
@onready var description = $Description
@onready var hover_name = $Description/VBoxContainer/PanelContainer/HBoxContainer/PanelContainer/Name
@onready var hover_body = $Description/VBoxContainer/Label
@onready var sell_panel_container = $SellPanelContainer
var mahjong_manager
var tile_select
var popup_tile_select
var mana_bar
var shop_root

#  diffrent item ids. also used as translation keys. do NOT assign custom values to keys,
# it'll break translation support!
enum TYPES {ITEM_NONE, ITEM_ERASER, ITEM_WIND_MAGNET, ITEM_BATTERY, ITEM_KAN_SWAP, ITEM_PIN_DUPE, ITEM_SOU_ADJ, ITEM_AKAFY, ITEM_POCCHI, ITEM_MAN_TERM, ITEM_DRAGON_CYCLE, ITEM_SUJI_OFFSET, ITEM_COLOR_SHIFT, ITEM_WIND_ROT}
#  items either use mana, charge themselves, or are one-time use
@export var type: TYPES = TYPES.ITEM_NONE
const COOLD = [     0,          48,               15,           24,            70,            44,           52,         61,          59,            36,                31,               32,               43,            27]
#  if true for this item, then modifications made to a tile are permanent.
# play around with this a little, dont want you to completely garbage your
# wall but it makes decisions more interesting
const PERMANENT = [false,    false,            false,        false,         false,          true,         true,      false,        true,          true,              true,             true,             true,          true]

enum CH_TYPES {ONCE, MANA, TIMR}
# make sure to set BEFORE calling _ready()!
@export var charge_type = CH_TYPES.TIMR
#  only used if the charge type is TIMR, tracks cooldown
var cooldown_counter = 0

# link self up if already added to tree. debug and reload use
@export var activate_self = false

# rememvers selected tiles, for example if necessary to select two tiles
var selected_tile_memory = []

# type is assigned before ready is called
func _ready():
	connect("mouse_entered", _mouse_entered)
	connect("mouse_exited", _mouse_exited)
	_mouse_exited()
	
	#  when in the shop, don't block the button.
	# cleared when `activate()` is called
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	cooldown_counter = COOLD[type]
	
	hover_body.clear()
	
	#  hovertexting. little hacky looking but godot preserves enum keys as strings,
	# might as well make use of it
	var string_id = TYPES.keys()[type]
	hover_name.text = tr(string_id)
	hover_body.append_text(tr(string_id + "_DESC"))
	
	
	hover_body.append_text("\n" + tr("ITEM_IS_TEMPORARY" if !PERMANENT[type] else "ITEM_IS_PERMANENT"))
	hover_body.append_text("[right][color=%s]" % COL.LBLUE)
	# additional gfx that vary based on type
	match charge_type:
		CH_TYPES.ONCE:
			hover_body.append_text(tr("ITEM_ONE_TIME"))
			panel_container.get_theme_stylebox("panel").region_rect.position.x = 8 * 3
		CH_TYPES.MANA:
			hover_body.append_text(tr("ITEM_CONSUME_MANA") % COOLD[type])
			panel_container.get_theme_stylebox("panel").region_rect.position.x = 8 * 1
		CH_TYPES.TIMR:
			hover_body.append_text(tr("ITEM_COOLDOWN") % COOLD[type])
			panel_container.get_theme_stylebox("panel").region_rect.position.x = 8 * 2
	
	
	sprite_2d.frame_coords.x = type % sprite_2d.hframes
	update_graphics(9999)
	
	if activate_self:
		activate(%MahjongManager, %TileSelectPanel, %PopupTileSelector, %ManaBar, %ShopRoot)
	
	panel_container.visible = true
	counter_label.text = str(COOLD[type])
	if charge_type == CH_TYPES.ONCE:
		counter_label.text = str(1)
	#decrement()

#  called after purchase, not when added to a purchaseable. also called by self
# on `_ready()` if appropriate.
func activate(mm: MahjongManager, ts: Node, pts: Node, mb: Node, shop: Node):
	# the parent exists in the same scene as these
	mahjong_manager = mm
	tile_select = ts
	popup_tile_select = pts
	mana_bar = mb
	shop_root = shop
	
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	cooldown_counter = 0
	
	update_graphics(mana_bar.mana)


func _use():
	# determine if can use atm.
	match charge_type:
		CH_TYPES.ONCE:
			pass
		CH_TYPES.MANA:
			if !mana_bar:
				return
			if !mana_bar.can_use_mana(COOLD[type]):
				return
		CH_TYPES.TIMR:
			if cooldown_counter > 0:
				return
	
	
	# not activated yet check
	if !mahjong_manager:
		return
	if mahjong_manager._state != MahjongManager.STATE_ACTIONABLE:
		return
	
	match type:
		TYPES.ITEM_NONE:
			#actual code here
			pass
		
		TYPES.ITEM_ERASER:
			# delete the old tile
			_delete_canon(mahjong_manager.tsumo)
			# old tile is cleared completely, dont maintain reference
			mahjong_manager.tsumo = null
			mahjong_manager.do_tsumo(MTile.new(MTile.SUITS.SPECIAL,MTile.SPECIALS.HAKU))
			
		TYPES.ITEM_WIND_MAGNET:
			var wind_ids = []
			for w in MTile.WINDS:
				wind_ids.append(MTile.gen_id(MTile.SUITS.SPECIAL, w))
			
			mahjong_manager.swap_in_next_theoretical_tsumo(wind_ids)
			
		TYPES.ITEM_BATTERY:
			# decrement other counters
			for i in get_parent().get_children():
				if i == self:
					continue
				i.decrement(9)
			
		TYPES.ITEM_KAN_SWAP:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a tile to swap in.")
			return # more steps to follow so we skip over updating the counter
			
		TYPES.ITEM_PIN_DUPE:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a Pin to be swapped.")
			return
			
		TYPES.ITEM_SOU_ADJ:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a Sou to be swapped.")
			return
			
		TYPES.ITEM_AKAFY:
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
				# escape case for all aka
				if i == ii:
					break
		
		TYPES.ITEM_POCCHI:
			mahjong_manager.tsumo.pocchi = true
			
			# it's permananent, so assign canon and queue redraw
			_try_make_permanent(mahjong_manager.tsumo, type)
			#mahjong_manager.tsumo.canon_tile.pocchi = true
			#mahjong_manager.tile_counter.emit_signal("updated")
			
			mahjong_manager.gui_manager.update_tsumo([mahjong_manager.tsumo])
			
		
		TYPES.ITEM_MAN_TERM:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a Man to be swapped.")
			return
		
		TYPES.ITEM_DRAGON_CYCLE:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a Dragon to cycle.")
			return
		
		TYPES.ITEM_SUJI_OFFSET:
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
		
		TYPES.ITEM_COLOR_SHIFT:
			var tile = mahjong_manager.tsumo
			if !MTile.NUMERALS.has(tile.suit):
				return
			
			mahjong_manager.stall_for_external_select()
			
			var suits = MTile.NUMERALS.duplicate()
			suits.erase(tile.suit)
			var new_tiles = []
			for s in suits:
				new_tiles.append(MTile.new(s, tile.value))
			popup_tile_select.set_tiles(new_tiles)
			popup_tile_select.request_tile_select(self)
			tile_select.update_text("Select a new suit.")
		
		TYPES.ITEM_WIND_ROT:
			mahjong_manager.request_tile_select(self, true)
			tile_select.update_text("Select a Wind to be rotated.")
			return
	
	#  default item behaviour assumes the usage is immediate, if not
	# call return in switch above.
	_expend_resource()


#  simple checker called by `MahjongManager to ask if a tile is valid. pindupe
# for example only accepts pins. 
#  default behavior is to return TRUE!
func tile_valid(tile: MTile):
	match type:
		TYPES.ITEM_PIN_DUPE:
			if tile.suit != MTile.SUITS.PIN:
				return false
		TYPES.ITEM_SOU_ADJ:
			if tile.suit != MTile.SUITS.SOU:
				return false
		TYPES.ITEM_MAN_TERM:
			if tile.suit != MTile.SUITS.MAN:
				return false
		TYPES.ITEM_DRAGON_CYCLE:
			if tile.suit != MTile.SUITS.SPECIAL or !MTile.DRAGONS.has(tile.value):
				return false
		TYPES.ITEM_WIND_ROT:
			if tile.suit != MTile.SUITS.SPECIAL or !MTile.WINDS.has(tile.value):
				return false
	return true


#  some items require an item to be selected. we take advantage of `MahjongManager`'s
# existing code to prompt selection, then do with it what we will down here.
func tile_selected(tile: MTile):
	match type:
		TYPES.ITEM_KAN_SWAP:
			var t = mahjong_manager.get_and_overwrite_most_recent_kan_dora(tile)
			mahjong_manager.add_to_hand_and_update(t)
			
		TYPES.ITEM_PIN_DUPE:
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
				_try_make_permanent(new_t, type)
				mahjong_manager.add_to_hand_and_update(new_t)
				selected_tile_memory.clear()
		
		TYPES.ITEM_SOU_ADJ:
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
				_try_make_permanent(new_t, type)
				mahjong_manager.add_to_hand_and_update(new_t)
				selected_tile_memory.clear()
		
		TYPES.ITEM_MAN_TERM:
			var new_tile = tile.duplicate()
			new_tile.value = 1 if randi()%1 else 9
			
			if tile.value < 5:
				new_tile.value = 9
			elif tile.value > 5:
				new_tile.value = 1
			
			new_tile.former = tile
			_try_make_permanent(new_tile, type)
			mahjong_manager.add_to_hand_and_update(new_tile)
		
		TYPES.ITEM_DRAGON_CYCLE:
			if selected_tile_memory.size() == 0:
				var val
				match tile.value:
					MTile.SPECIALS.HAKU:
						val = MTile.SPECIALS.HATSU
					MTile.SPECIALS.HATSU:
						val = MTile.SPECIALS.CHUN
					MTile.SPECIALS.CHUN:
						val = MTile.SPECIALS.HAKU
					# prompt selection for kin
					MTile.SPECIALS.KIN:
						var new_tiles = [MTile.new(MTile.SUITS.SPECIAL,MTile.SPECIALS.HAKU),MTile.new(MTile.SUITS.SPECIAL,MTile.SPECIALS.HATSU),MTile.new(MTile.SUITS.SPECIAL,MTile.SPECIALS.CHUN)]
						mahjong_manager.complete_tile_select()
						mahjong_manager.stall_for_external_select()
						popup_tile_select.set_tiles(new_tiles)
						popup_tile_select.request_tile_select(self)
						tile_select.update_text("Select a Dragon to become.")
						return
				var new_tile = tile.duplicate()
				new_tile.former = tile
				new_tile.value = val
				_try_make_permanent(new_tile, type)
				mahjong_manager.add_to_hand_and_update(new_tile)
			else:
				var new_t = selected_tile_memory[0].duplicate()
				new_t.value = tile.value
				new_t.former = tile
				_try_make_permanent(new_t, type)
				mahjong_manager.add_to_hand_and_update(new_t)
				selected_tile_memory.clear()
		
		TYPES.ITEM_SUJI_OFFSET:
			var new_tile = mahjong_manager.tsumo.duplicate()
			new_tile.value = tile.value
			new_tile.former = mahjong_manager.tsumo
			mahjong_manager.tsumo = null
			_try_make_permanent(new_tile, type)
			mahjong_manager.add_to_hand_and_update(new_tile)
		
		TYPES.ITEM_COLOR_SHIFT:
			var new_tile = mahjong_manager.tsumo.duplicate()
			new_tile.suit = tile.suit
			new_tile.former = mahjong_manager.tsumo
			mahjong_manager.tsumo = null
			_try_make_permanent(new_tile, type)
			mahjong_manager.add_to_hand_and_update(new_tile)
		
		TYPES.ITEM_WIND_ROT:
			if selected_tile_memory.size() == 0:
				selected_tile_memory.append(tile)
				
				
				# inelegant. i do not care
				var new_tiles_vals = []
				match tile.value:
					MTile.SPECIALS.NORTH:
						new_tiles_vals = [MTile.SPECIALS.EAST, MTile.SPECIALS.WEST]
					MTile.SPECIALS.EAST:
						new_tiles_vals = [MTile.SPECIALS.SOUTH, MTile.SPECIALS.NORTH]
					MTile.SPECIALS.SOUTH:
						new_tiles_vals = [MTile.SPECIALS.EAST, MTile.SPECIALS.WEST]
					MTile.SPECIALS.WEST:
						new_tiles_vals = [MTile.SPECIALS.SOUTH, MTile.SPECIALS.NORTH]
					MTile.SPECIALS.UP:
						new_tiles_vals = [MTile.SPECIALS.EAST, MTile.SPECIALS.SOUTH, MTile.SPECIALS.WEST, MTile.SPECIALS.NORTH]
				
				var new_tiles = []
				for i in new_tiles_vals:
					new_tiles.append(MTile.new(MTile.SUITS.SPECIAL, i))
				
				# override def behavior
				mahjong_manager.complete_tile_select()
				mahjong_manager.stall_for_external_select()
				popup_tile_select.set_tiles(new_tiles)
				popup_tile_select.request_tile_select(self)
				tile_select.update_text("Select a Wind to become.")
				return
			else:
				var new_t = selected_tile_memory[0].duplicate()
				#new_t.suit = tile.suit
				new_t.value = tile.value
				new_t.former = tile
				
				_try_make_permanent(new_t, type)
				mahjong_manager.add_to_hand_and_update(new_t)
				selected_tile_memory.clear()
	
	# default completion behaviour
	mahjong_manager.complete_tile_select()
	popup_tile_select.set_tiles([])
	tile_select.update_text("")
	_expend_resource()

func set_shop_graphics():
	update_graphics(9999, true)

# update the counter. and the gfx. `force` forces the item to appear charged
func update_graphics(mana: int, force: int = false):
	# custom mouse overlay if usable
	var cant_use = false
	
	match charge_type:
		CH_TYPES.ONCE:
			cant_use = true
		CH_TYPES.MANA:
			cant_use = COOLD[type] > mana
			
		CH_TYPES.TIMR:
			cant_use = cooldown_counter > 0
			panel_container.visible = cant_use or force
			counter_label.text = str(maxi(0,cooldown_counter))
	
	
	sprite_2d.frame_coords.y = (type / sprite_2d.hframes) * (2 + int(cant_use and !force))
	
	if !cant_use:
		mouse_default_cursor_shape = CURSOR_POINTING_HAND
	else:
		mouse_default_cursor_shape = CURSOR_ARROW


#  if a tile effect is supposed to be permanent this does it.
# otherwise do nothing. this is mostly for speed of development
func _try_make_permanent(new: MTile, type: int):
	if PERMANENT[type]:
		new.canon_tile.assign_tile(new)
		mahjong_manager.tile_counter.emit_signal("updated")

func _delete_canon(tile: MTile):
	assert(tile.canon_tile != null)
	mahjong_manager.tile_counter.remove_tile(tile.canon_tile)
	mahjong_manager.tile_counter.emit_signal("updated")


# called on item use, spends mana/cooldown/the item as appropriate.
func _expend_resource():
	match charge_type:
		CH_TYPES.ONCE:
			queue_free()
		CH_TYPES.MANA:
			mana_bar.use_mana(COOLD[type])
			get_parent().update_tile_graphics()
		CH_TYPES.TIMR:
			cooldown_counter = COOLD[type]
			decrement(0)
			

func decrement(amount: int = 1):
	if charge_type != CH_TYPES.TIMR:
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
			# we're kinda chaining visible checks here, not the biggest fan
			if !sell_panel_container.visible:
				_use()
			else:
				queue_free()
				shop_root.adjust_money(1)

func _mouse_entered():
	description.animate_in()
	# we're kinda chaining visible checks here, not the biggest fan
	if shop_root and shop_root.visible:
		sell_panel_container.animate_in()
		mouse_default_cursor_shape = CURSOR_POINTING_HAND
func _mouse_exited():
	description.animate_out()
	sell_panel_container.animate_out()
	mouse_default_cursor_shape = CURSOR_ARROW
