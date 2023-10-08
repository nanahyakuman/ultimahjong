extends Node

@onready var gui_manager = $"../GUIManager"


var OPPONENT_DISCARDS = 3
var DEFAULT_KAN_SIZE = 5

var wall = []
var hand = []
var tsumo
var discard = []
var opp_discard = []
var kan_dora = []
var ura_dora = []

enum WINDS {EAST, SOUTH, WEST, NORTH}
var prevalent_wind = WINDS.EAST
var SEAT = WINDS.EAST

var actionable = true

func _ready():
	await get_tree().process_frame
	
	init_wall()
	
	gui_manager.update_discard([])
	gui_manager.update_opp_discard([])
	
	draw_hand()
	draw_tile()
	
	for i in DEFAULT_KAN_SIZE:
		draw_kan_dora()
	gui_manager.update_wall_count(wall.size())


# default tiles
func init_wall():
	for i in MTile.SUITS.values():
		if i == MTile.SUITS.SPECIAL:
			for j in range(1, MTile.SPECIALS.values().size()):
				wall.append(MTile.new(i,j))
		else:
			for j in range(1,10):
				wall.append(MTile.new(i,j))
	
	# this gives me anxiety but appears safe
	wall.append_array(wall)
	wall.append_array(wall)
	wall.shuffle()

func draw_hand():
	for i in 13:
		hand.append(wall.pop_back())
	update_hand_label()

func draw_kan_dora():
	kan_dora.append(wall.pop_back())
	ura_dora.append(wall.pop_back())
	gui_manager.update_kan_dora(kan_dora)

func draw_tile():
	await do_opp_discard()
	
	tsumo = wall.pop_back()
	gui_manager.update_tsumo([tsumo])
	
	gui_manager.update_wall_count(wall.size())

func do_opp_discard():
	actionable = false
	
	await get_tree().create_timer(.1).timeout
	
	for i in OPPONENT_DISCARDS:
		opp_discard.append(wall.pop_back())
		gui_manager.update_opp_discard(opp_discard)
		gui_manager.update_wall_count(wall.size())
		await get_tree().create_timer(.3).timeout
	
	actionable = true

#  for physical buttons. note only tiles we define as
# `clickable` can even be clicked, and since this is only
# for tiles in hand, we know that if a tile is clicked
# it's in hand.
func tile_graphic_clicked(tile: MTile):
	if actionable:
		draw_and_discard(tile)

func draw_and_discard_index(i: int):
	if i == 13:
		draw_and_discard(tsumo)
	else:
		draw_and_discard(hand[i])

func draw_and_discard(discardee: MTile):
	hand.append(tsumo)
	hand.erase(discardee)
	#TileGraphicKnower.highlight_matching_tiles(discardee.get_id(), false)
	update_hand_label()
	discard.append(discardee)
	gui_manager.update_discard(discard)
	gui_manager.update_tsumo([])
	
	TileGraphicKnower.highlight_matching_tiles(discardee, false)
	draw_tile()
	#TileGraphicKnower.highlight_matching_tiles(discardee, false)
	

func update_hand_label():
	hand.sort_custom(Callable(MTile, "tile_compare"))
	gui_manager.update_hand(hand)
