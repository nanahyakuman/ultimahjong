extends Control
class_name TileGraphic

@onready var sprite = $Sprite2D
@onready var sides = $Tilesides
@onready var sim_tile_highlight = $SimTileHighlight
@onready var adj_tile_highlight = $AdjTileHighlight
@onready var call_tile_highlight = $CallTileHighlight
@onready var dora_sprite = $Sprite2D/TileDora
@onready var flicker = $Flicker
@onready var custom_overlays = $Sprite2D/CustomOverlays

@export var tile_size = Vector2(16,32)
var in_hand = false

@export var suit = 0
@export var value = 0
var tile = null
enum {SIDE_RIGHT, SIDE_TOP, SIDE_LEFT, SIDE_BOT}
var visible_side = SIDE_BOT
var _reversed = false
var _face_upsidedown = false

# hover text name
@export var verbose = false

func _ready():
	TileGraphicKnower.highlight.connect(self._highlight_requested)
	TileGraphicKnower.new_dora.connect(self._new_dora)

# remaned this to be more accurate, remove comment after update!
func assign_tile(t: MTile):
	if !t:
		return
	
	suit = t.suit
	value = t.value
	tile = t
	
	sprite.region_rect = get_tile_segment(tile)
	
	_new_dora(TileGraphicKnower.dora_ids)
	
	clear_custom_overlays()
	if t.former:
		assign_custom_overlay(t.suit)
	
	if t.pocchi:
		assign_custom_overlay(OVERLAY_POCCHI)

func get_tile_segment(t: MTile) -> Rect2:
	var x = (t.value-1) * tile_size.x
	var y = roundi(log(t.suit)/log(2)) * tile_size.y
	if tile.aka:
		y += tile_size.y * 5
	
	# this texture is only visible if you messed up somehow
	if t.suit == MTile.SUITS.NONE or t.value == 0:
		x = 9 * tile_size.x
		y = 7 * tile_size.y
	
	return Rect2(x,y, tile_size.x, tile_size.y)

# -1 to hide entirely
func assign_visible_side(side: int):
	visible_side = side
	if side == -1:
		sides.visible = false
		sim_tile_highlight.frame_coords.x = 4
		adj_tile_highlight.frame_coords.x = 4
	elif !_reversed:
		sides.frame = side
		sim_tile_highlight.frame_coords.x = side
		adj_tile_highlight.frame_coords.x = side
	else:
		sides.frame = 4 + side
		sim_tile_highlight.frame_coords.x = side
		adj_tile_highlight.frame_coords.x = side
	
	
	sprite.visible = !_reversed

func set_reversed(rv: bool):
	_reversed = rv
	assign_visible_side(visible_side)

func get_reversed():
	return _reversed

func set_rotated(ud: bool):
	_face_upsidedown = ud
	sprite.rotation = int(_face_upsidedown) * PI
	sprite.position = Vector2(16,26) * int(_face_upsidedown)

signal tile_graphic_clicked

func _gui_input(event):
	# can only click on tiles in hand
	if in_hand:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				TileGraphicKnower.highlight_matching_tiles(tile, false)
				emit_signal("tile_graphic_clicked", tile)
				#TileGraphicKnower.highlight_matching_tiles(tile, true)
			
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				print(tile.get_id())



#  code for highlights. `TileGraphicKnower` sends out actual signals
# for tiles to highlight themselves
func _on_mouse_entered():
	# reversed tiles are hidden
	if !_reversed:
		TileGraphicKnower.highlight_matching_tiles(tile, true)
	if verbose:
		CursorText.set_text(tile.get_name())
func _on_mouse_exited():
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
		var find = adjs.find(tile.get_id())
		if find != -1:
			adj_tile_highlight.visible = val
			adj_tile_highlight.scale.x = 1-(find*2)
			adj_tile_highlight.position.x = 8-find
			#flicker.visible = val
			

func direct_request_highlight(val: bool):
	call_tile_highlight.visible = val


func _new_dora(ids: Array):
	dora_sprite.visible = ids.has(tile.get_id())

# custom overlays to indicate tiles that aren't actually real.
enum {
	OVERLAY_PINDUPE = MTile.SUITS.PIN, OVERLAY_SOUDUPE = MTile.SUITS.SOU, OVERLAY_MANDUPE = MTile.SUITS.MAN,
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



