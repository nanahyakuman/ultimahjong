extends Control
class_name TileGraphic

@onready var sprite = $Rotator/Sprite2D
@onready var tile_rear = $Rotator/TileRear
# the sprite in use for special tiles
@onready var unique_sprite = $Rotator/UniqueSprite
@onready var sides = $Rotator/Tilesides
@onready var sim_tile_highlight = $Rotator/SimTileHighlight
@onready var adj_tile_highlight = $Rotator/AdjTileHighlight
@onready var call_tile_highlight = $Rotator/CallTileHighlight
@onready var dora_sprite = $Rotator/Sprite2D/TileDora
@onready var flicker = $Rotator/Flicker
@onready var custom_overlays = $Rotator/Sprite2D/CustomOverlays
@onready var rotator = $Rotator

@export var tile_size = Vector2(16,32)

@export var suit = 0
@export var value = 0
var tile = null
enum {SIDE_NONE = -1, SIDE_RIGHT, SIDE_TOP, SIDE_LEFT, SIDE_BOT}
var visible_side = SIDE_BOT
var _reversed = false
var _rotated: bool = false

# hover text name
@export var verbose = false

func _ready():
	TileGraphicKnower.highlight.connect(self._highlight_requested)
	TileGraphicKnower.new_dora.connect(self._new_dora)
	TileGraphicKnower.change_texture.connect(self._assign_tileset)
	_assign_tileset(TileGraphicKnower.tileset)

func assign_tile(t: MTile):
	if !t:
		return
	
	suit = t.suit
	value = t.value
	tile = t
	
	if tile.unique_type == MTile.UNIQUE.NOT:
		sprite.region_rect = get_tile_segment(tile)
		sprite.visible = true
		unique_sprite.visible = false
		sides.texture = load("res://image/tile/tilesides.png")
	else:
		get_unique_sprite(tile)
		sprite.visible = false
		unique_sprite.visible = true
	
	_new_dora(TileGraphicKnower.dora_ids)
	
	clear_custom_overlays()
	if t.former:
		assign_custom_overlay(t.suit)
	
	if t.pocchi:
		assign_custom_overlay(OVERLAY_POCCHI)

func get_tile_segment(t: MTile) -> Rect2:
	var x = (t.value-1) * tile_size.x
	var y = roundi(log(t.suit)/log(2)) * tile_size.y
	if tile.color == MTile.COL_AKA:
		y += tile_size.y * 6
	elif tile.color == MTile.COL_AO:
		x += tile_size.x * 11
	elif tile.color == MTile.COL_KIN:
		y += tile_size.y * 6
		x += tile_size.x * 11
	
	# this texture is only visible if you messed up somehow
	if t.suit == MTile.SUITS.NONE or t.value == 0:
		x = 10 * tile_size.x
		y = 7 * tile_size.y
	
	return Rect2(x,y, tile_size.x, tile_size.y)

#  assigns a unique sprite as necessary. lots of pretty bespoke code is gonna
# gho here long term.
#  broadly, for every unique tile, thgere should be a matching sprite and 
# sides sprite, each inheriting their name from its dict key. the sprite should
# be a sheet of 32x things, and the code here should assign which thing it is.
func get_unique_sprite(t: MTile):
	var path = "res://image/tile/custom_tile/%s.png"
	var sidespath = "res://image/tile/custom_tile/%s_SIDES.png"
	unique_sprite.texture = load(path % MTile.UNIQUE.keys()[t.unique_type])
	sides.texture = load(sidespath % MTile.UNIQUE.keys()[t.unique_type])
	
	#  reset position. redundant a lot of the time but convenient bc we dont 
	# need to do any assigning for unique tiles that only have one frame.
	unique_sprite.region_rect.position = Vector2.ZERO
	
	match t.unique_type:
		MTile.UNIQUE.D6:
			unique_sprite.region_rect.position.x = 32 * (t.value-1)
			unique_sprite.region_rect.position.y = 32 * log(t.suit)/log(2)

# -1 to hide entirely.
func assign_visible_side(side: int):
	var calc_side = side + (int(_rotated) * -3)
	
	visible_side = side
	if visible_side == SIDE_NONE:
		sides.visible = false
		sim_tile_highlight.frame_coords.x = 4
		adj_tile_highlight.frame_coords.x = 4
	elif !_reversed:
		sides.frame = calc_side
		sim_tile_highlight.frame_coords.x = calc_side
		adj_tile_highlight.frame_coords.x = calc_side
	else:
		sides.frame = 4 + calc_side
		sim_tile_highlight.frame_coords.x = calc_side
		adj_tile_highlight.frame_coords.x = calc_side
	
	
	sprite.visible = !_reversed and tile.unique_type == MTile.UNIQUE.NOT
	tile_rear.visible = _reversed

func set_reversed(rv: bool):
	_reversed = rv
	assign_visible_side(visible_side)

func get_reversed():
	return _reversed

# only support 90deg to the right
func set_rotated(rotated: bool):
	_rotated = rotated
	custom_minimum_size = Vector2(16,26).rotated(float(rotated) * -PI/2)
	rotator.rotation = float(rotated) * PI/2
	rotator.position = Vector2(26,10) * int(rotated)
	
	assign_visible_side(visible_side)

signal tile_graphic_clicked

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			TileGraphicKnower.highlight_matching_tiles(tile, false)
			emit_signal("tile_graphic_clicked", tile)
			#TileGraphicKnower.highlight_matching_tiles(tile, true)
		
		# debug
#		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
#			print(tile.get_id())



#  code for highlights. `TileGraphicKnower` sends out actual signals
# for tiles to highlight themselves
func _on_mouse_entered():
	if tile:
		# reversed tiles are hidden
		if !_reversed:
			TileGraphicKnower.highlight_matching_tiles(tile, true)
		if verbose:
			CursorText.set_text(tile.get_name())
func _on_mouse_exited():
	if tile:
		if !_reversed:
			TileGraphicKnower.highlight_matching_tiles(tile, false)
		if verbose:
			CursorText.set_text("")

func _highlight_requested(id: int, adjs: Array, val: bool):
	if _reversed:
		return
	if tile:
		if id == tile.get_id():
			sim_tile_highlight.visible = val
			flicker.visible = val
			return
		# left or right visibility
#		var find = adjs.find(tile.get_id())
#		if find != -1:
#			adj_tile_highlight.visible = val
#			adj_tile_highlight.scale.x = 1-(find*2)
#			adj_tile_highlight.position.x = 8-find
#			#flicker.visible = val
#

func direct_request_highlight(val: bool):
	call_tile_highlight.visible = val


func _new_dora(ids: Array):
	if tile:
		dora_sprite.visible = ids.has(tile.get_id())

# custom overlays to indicate tiles that aren't actually real.
enum {
	OVERLAY_PINDUPE = MTile.SUITS.PIN, OVERLAY_SOUDUPE = MTile.SUITS.SOU, OVERLAY_MANDUPE = MTile.SUITS.MAN, OVERLAY_DRAGDUPE = MTile.SUITS.SPECIAL,
	OVERLAY_POCCHI
}
func assign_custom_overlay(overlay_type: int):
	var new_tex = null
	match overlay_type:
		OVERLAY_PINDUPE:
			new_tex = load("res://image/tile/fx/pindupe_indicator.png")
		OVERLAY_SOUDUPE:
			new_tex = load("res://image/tile/fx/soudupe_indicator.png")
		OVERLAY_MANDUPE:
			new_tex = load("res://image/tile/fx/mandupe_indicator.png")
		OVERLAY_DRAGDUPE:
			new_tex = load("res://image/tile/fx/dragdupe_indicator.png")
		OVERLAY_POCCHI:
			new_tex = load("res://image/tile/fx/pocchi.png")
	
	# try to take advantage of existing overlay, else create new one
	if new_tex:
		for c in custom_overlays.get_children():
			if c.texture == null:
				c.texture = new_tex
				return
		
		var a = Sprite2D.new()
		a.texture = new_tex
		a.centered = false
		custom_overlays.add_child(a)

func clear_custom_overlays():
	for c in custom_overlays.get_children():
		c.texture = null


func _assign_tileset(tex: Texture2D):
	sprite.texture = tex
