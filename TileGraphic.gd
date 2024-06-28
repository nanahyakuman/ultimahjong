extends Control
class_name TileGraphic

@onready var numeral = $Rotator/NumeralGraphic
# the sprite in use for special tiles
@onready var unique_sprite = $Rotator/UniqueSprite
@onready var tile_material = $Rotator/TileMaterial
@onready var sim_tile_highlight = $Rotator/SimTileHighlight
@onready var adj_tile_highlight = $Rotator/AdjTileHighlight
@onready var call_tile_highlight = $Rotator/CallTileHighlight
@onready var dora_sprite = $Rotator/NumeralGraphic/TileDora
@onready var flicker = $Rotator/Flicker
@onready var custom_overlays = $Rotator/NumeralGraphic/CustomOverlays
@onready var rotator = $Rotator
# display for unique items that can only be used once a round
@onready var already_used_indicator = $AlreadyUsedIndicator
# sidebar greyer
@onready var already_discarded = $Rotator/AlreadyDiscarded

var tile_size = Vector2(16,32)
var material_size = Vector2(32,48)
var WESTERNIZE_SHEET_WIDTH = 20

var tile: MTile = null
enum {SIDE_RIGHT, SIDE_TOP, SIDE_BOT}
var visible_side = SIDE_BOT
var _reversed: bool = false
var _rotated: bool = false

# hover text name
var verbose = false

func _ready():
	TileGraphicKnower.highlight.connect(self._highlight_requested)
	TileGraphicKnower.new_dora.connect(self._new_dora)
	TileGraphicKnower.change_texture.connect(self.retexture_self)

#  called when tilegraphicknower's westernization settings are changed,
# to update tiles on demand
func retexture_self():
	assign_tile(tile)

func assign_tile(t: MTile):
	if !t:
		return
	
	tile = t
	
	if tile.unique_type == MTile.UNIQUE.NOT:
		# numeral segment
		numeral.region_rect = get_tile_segment(tile)
		tile_material.texture = load("res://image/tile/tilesides.png")
		numeral.visible = true
		unique_sprite.visible = false
	else:
		get_unique_sprite(tile)
		numeral.visible = false
		unique_sprite.visible = true
	
	_new_dora(TileGraphicKnower.dora_ids)
	
	clear_custom_overlays()
	
	if t.pocchi:
		assign_custom_overlay(OVERLAY_POCCHI)
	
	assign_visible_side(visible_side)
	
	if verbose:
		already_discarded.visible = t.discarded
	
	#  conveniaent place to call it, because any tile that does anything
	# should retriggier gui.update_hand, calling this
	update_used_graphic()

func get_tile_segment(t: MTile) -> Rect2:
	var x = (t.value-1) * tile_size.x
	var y = roundi(log(t.suit)/log(2)) * tile_size.y
	
	match tile.color:
		MTile.COLS.AO:
			x += tile_size.x * 10
		MTile.COLS.AKA:
			y += tile_size.y * 6
		MTile.COLS.KIN:
			y += tile_size.y * 6
			x += tile_size.x * 10
		MTile.COLS.MURASAKI:
			y += tile_size.y * 11
		MTile.COLS.MIDORI:
			y += tile_size.y * 11
			x += tile_size.x * 10
		MTile.COLS.KURO:
			y += tile_size.y * 16
	
	# various texture options
	match t.suit:
		MTile.SUITS.PIN:
			x += tile_size.x * WESTERNIZE_SHEET_WIDTH * TileGraphicKnower.pinsou_version
		MTile.SUITS.SOU:
			x += tile_size.x * WESTERNIZE_SHEET_WIDTH * TileGraphicKnower.pinsou_version
		MTile.SUITS.CHO:
			x += tile_size.x * WESTERNIZE_SHEET_WIDTH * TileGraphicKnower.pinsou_version
		
		MTile.SUITS.MAN:
			x += tile_size.x * WESTERNIZE_SHEET_WIDTH * TileGraphicKnower.man_version
		
		MTile.SUITS.SPECIAL:
			x += tile_size.x * WESTERNIZE_SHEET_WIDTH * TileGraphicKnower.wind_version
		MTile.SUITS.FLOWER:
			x += tile_size.x * WESTERNIZE_SHEET_WIDTH * TileGraphicKnower.wind_version
	
	return Rect2(x,y, tile_size.x, tile_size.y)

#  assigns a unique sprite as necessary. lots of pretty bespoke code is gonna
# gho here long term.
#  broadly, for every unique tile, thgere should be a matching sprite and 
# sides sprite, each inheriting their name from its dict key. the sprite should
# be a sheet of 32x things, and the code here should assign which thing it is.
#  the sides should be formatted the same as tilesides.png, although we're kinda
# ignoring the reversibility code in ankan rn, so tiles always appear up. this is 
# slightly disappointing ig but i reeally dont want to draw twice as many sprites
# for every unique tile just so you can visually ankan them. regardless you MUST define all
# 8 side rotations, the bottom 4 should be identical to those in base tilesides!
func get_unique_sprite(t: MTile):
	var path = "res://image/tile/custom_tile/%s.png"
	var sidespath = "res://image/tile/custom_tile/%s_SIDES.png"
	unique_sprite.texture = load(path % MTile.UNIQUE.keys()[t.unique_type])
	tile_material.texture = load(sidespath % MTile.UNIQUE.keys()[t.unique_type])
	
	#  reset position. redundant a lot of the time but convenient bc we dont 
	# need to do any assigning for unique tiles that only have one frame.
	unique_sprite.region_rect.position = Vector2.ZERO
	
	match t.unique_type:
		MTile.UNIQUE.D6:
			unique_sprite.region_rect.position.x = 32 * (t.value-1)
			unique_sprite.region_rect.position.y = 32 * log(t.suit)/log(2)
		MTile.UNIQUE.DOMINO: # this implementation is really wasteful but whatever
			unique_sprite.region_rect.position.x = 32 * (t.value-1)
			unique_sprite.region_rect.position.y = 32 * (t.unique_args[0]-1)

func assign_visible_side(side: int):
	# forgot why we do this at all but for now just ignore negatives
	if side == -1:
		return
	
	visible_side = side
	
	# override rotated tiles to always be sideways
	var calc_side = SIDE_LEFT if _rotated else side
	
	# tile rotation /and/ material
	tile_material.region_rect.position.x = (calc_side + 3*tile.material ) * material_size.x
	
	sim_tile_highlight.frame_coords.x = calc_side
	adj_tile_highlight.frame_coords.x = calc_side
	
	tile_material.region_rect.position.y = int(_reversed) * material_size.y
	
	# show numeral (and sides, implicitly) or not
	if !_reversed:
		if !tile:
			numeral.visible = true
		elif tile.unique_type == MTile.UNIQUE.NOT:
			numeral.visible = true
		else:
			numeral.visible = false
	else:
		numeral.visible = false
	
	numeral.visible = !_reversed
	unique_sprite.visible = !_reversed
	# hide normal sprite if we're unique
	if tile:
		if tile.unique_type != MTile.UNIQUE.NOT:
			numeral.visible = false

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


func update_used_graphic():
	already_used_indicator.visible = tile.already_used

signal tile_graphic_clicked

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			TileGraphicKnower.highlight_matching_tiles(tile, false)
			emit_signal("tile_graphic_clicked", tile, false)
			#TileGraphicKnower.highlight_matching_tiles(tile, true)
		
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			TileGraphicKnower.highlight_matching_tiles(tile, false)
			emit_signal("tile_graphic_clicked", tile, true)



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
	OVERLAY_POCCHI
}
func assign_custom_overlay(overlay_type: int):
	var new_tex = null
	match overlay_type:
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
