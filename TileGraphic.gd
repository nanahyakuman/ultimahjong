extends Control
class_name TileGraphic

@onready var sprite = $Sprite2D
@onready var sides = $Tilesides
@onready var sim_tile_highlight = $BlueTileHighlight
@onready var adj_tile_highlight = $RedTileHighlight
@onready var call_tile_highlight = $RedTileHighlight2
@onready var dora_sprite = $Sprite2D/TileDora

@export var tile_size = Vector2(16,32)
var in_hand = false

@export var suit = 0
@export var value = 0
var tile = null
enum {SIDE_RIGHT, SIDE_TOP, SIDE_LEFT, SIDE_BOT}
var visible_side = SIDE_BOT
var _reversed = false
var _face_upsidedown = false

func _ready():
	TileGraphicKnower.highlight.connect(self._highlight_requested)
	TileGraphicKnower.new_dora.connect(self._new_dora)
	


func assign_suit_value(t: MTile):
	if !t:
		return
	
	suit = t.suit
	value = t.value
	tile = t
	
	sprite.region_rect = get_tile_segment(tile)
	
	_new_dora(TileGraphicKnower.dora_ids)

func get_tile_segment(t: MTile) -> Rect2:
	var x = (t.value-1) * tile_size.x
	var y = roundi(log(t.suit)/log(2)) * tile_size.y
	if tile.aka:
		y += tile_size.y * 4
	
	
	return Rect2(x,y, tile_size.x, tile_size.y)

func assign_visible_side(side: int):
	visible_side = side
	if !_reversed:
		sides.frame = side
	else:
		sides.frame = 4 + side
	
	sprite.visible = !_reversed

func set_reversed(rv: bool):
	_reversed = rv
	assign_visible_side(visible_side)

func set_upside_down(ud: bool):
	var _face_upsidedown = ud
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
			
#			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
#				print(tile.get_id())



#  code for highlights. `TileGraphicKnower` sends out actual signals
# for tiles to highlight themselves
func _on_mouse_entered():
	if !_reversed:
		TileGraphicKnower.highlight_matching_tiles(tile, true)
func _on_mouse_exited():
	if !_reversed:
		TileGraphicKnower.highlight_matching_tiles(tile, false)

func _highlight_requested(id: int, val: bool, is_adj: bool):
	if _reversed:
		return
	if tile:
		if id == tile.get_id():
			if !is_adj:
				sim_tile_highlight.visible = val
			else:
				adj_tile_highlight.visible = val

func direct_request_highlight(val: bool):
	call_tile_highlight.visible = val


func _new_dora(ids: Array):
	dora_sprite.visible = ids.has(tile.get_id())
