extends Control

const SIZE = 22

@export var tile_graphic: PackedScene
@export var tile_size = Vector2i(16,32)


@onready var mahjong_manager = %MahjongManager
@onready var hand = $All/SideSpacers/Tiles/HBoxContainer/Hand
@onready var tsumo = $All/SideSpacers/Tiles/HBoxContainer/Tsumo
@onready var discards = [$All/SideSpacers/Tiles/PDiscards, $All/SideSpacers/Tiles/PDiscards2]
@onready var opp_dcs = [$All/SideSpacers/Tiles/Discards2, $All/SideSpacers/Tiles/Discards3, $All/SideSpacers/Tiles/Discards4, $All/SideSpacers/Tiles/Discards5]
@onready var kan_pile = $All/SideSpacers/Tiles/KanPile/Top
@onready var kan_pile_bot = $All/SideSpacers/Tiles/KanPile/Bot
@onready var graphic_tile_counter = $"../../GraphicTileCounter"
@onready var prev_wind = $All/TableBottom/HBoxContainer/RoundWind/Sprite2D
@onready var seat_wind = $All/TableBottom/HBoxContainer/SittingWind/Sprite2D
@onready var made_calls = $MadeCalls
@onready var score_label = $TableTop/HBoxContainer/HBoxContainer/ScoreLabel
@onready var needed_score_label = $TableTop/HBoxContainer/HBoxContainer/NeededScoreLabel
@onready var score_mod_label = $TableTop/HBoxContainer/HBoxContainer/VBoxContainer/ScoreModLabel
@onready var score_mod_label_2 = $TableTop/HBoxContainer/HBoxContainer/VBoxContainer/ScoreModLabel2

# tracked so calls can highlight it. only modifed by `hand`.
var most_recent_discard = null

func _ready():
	pass

func update_hand(tiles: Array):
	_update_node(hand, tiles, true, TileGraphic.SIDE_TOP)
	
func update_discard(tiles: Array):
	for d in discards.size():
		_update_node(discards[d], tiles.slice(d*SIZE, d*SIZE+SIZE))

func update_opp_discard(tiles: Array):
	for d in opp_dcs.size():
		var ret = _update_node(opp_dcs[d], tiles.slice(d*SIZE, d*SIZE+SIZE))
		if ret:
			most_recent_discard = ret

func update_tsumo(tiles: Array):
	_update_node(tsumo, tiles, true, TileGraphic.SIDE_TOP)

func update_kan_dora(tiles: Array, covered: int):
	_update_node(kan_pile, tiles, false, TileGraphic.SIDE_BOT, covered)
	_update_node(kan_pile_bot, tiles, false, TileGraphic.SIDE_BOT, 9999)

func update_made_calls(groupings: Array):
	var tiles = []
	for g in groupings:
		for t in g.tiles:
			tiles.append(t)
	_update_node(made_calls, tiles)

# returns the final updated visible node
func _update_node(node: Node, tiles: Array, in_hand: bool = false, visible_side: int = TileGraphic.SIDE_BOT, reverse_count: int = -1):
	var existing_count = node.get_child_count()
	var ret = null
	for t in tiles.size():
		if t < existing_count:
			node.get_child(t).assign_tile(tiles[t])
			node.get_child(t).set_reversed(reverse_count > t)
		else:
			get_new_tile(tiles[t], node, in_hand, visible_side, reverse_count > t)
		
		var curr = node.get_child(t)
		if curr:
			curr.visible = true
			ret = curr
	
	for t in range(tiles.size(), existing_count):
		node.get_child(t).visible = false
	
	return ret

func get_new_tile(t: MTile, parent: Node, in_hand: bool, vis_side: int, reverse: bool):
	var a = tile_graphic.instantiate()
	parent.add_child(a)
	a.assign_tile(t)
	a.in_hand = in_hand
	a.connect("tile_graphic_clicked", mahjong_manager.tile_graphic_clicked)
	a.assign_visible_side(vis_side)
	a.set_reversed(reverse)
	return(a)

func update_winds(prev: int, seat: int):
	prev_wind.frame = prev
	seat_wind.frame = seat

func update_wall_count(c: int):
	graphic_tile_counter.update_wall_count(c)

func increment_dead_wall_count(c: int):
	graphic_tile_counter.increment_dead_wall_count(c)

func reset_dead_wall_count():
	graphic_tile_counter.reset_dead_wall_count()

func update_score(score: int, expected_score: int, expected_points_mod: int, expected_points_mod_mod: int):
	score_label.set_text_colorized(str(score))
	needed_score_label.set_text_colorized(str(expected_score))
	score_mod_label.text = "+%04d" % expected_points_mod
	score_mod_label_2.text = " +" + str(expected_points_mod_mod)
