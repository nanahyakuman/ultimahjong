extends Control
class_name TileGraphic

@onready var sprite = $Sprite2D
@onready var sides = $Tilesides
@onready var sim_tile_highlight = $SimTileHighlight
@onready var adj_tile_highlight = $AdjTileHighlight

@export var tile_size = Vector2(16,32)
@export var clickable = false

@export var suit = 0
@export var value = 0
var tile = null
enum {SIDE_RIGHT, SIDE_TOP, SIDE_LEFT, SIDE_BOT}
var visible_side = SIDE_BOT
var _reversed = false


func _ready():
	TileGraphicKnower.highlight.connect(self._highlight_requested)


func assign_suit_value(t: MTile):
	if !t:
		return
	
	suit = t.suit
	value = t.value
	tile = t
	
	sprite.region_rect = get_tile_segment(tile)

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


signal tile_graphic_clicked

func _gui_input(event):
	if clickable:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				#TileGraphicKnower.highlight_matching_tiles(tile, false)
				emit_signal("tile_graphic_clicked", tile)
				#TileGraphicKnower.highlight_matching_tiles(tile, true)



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
