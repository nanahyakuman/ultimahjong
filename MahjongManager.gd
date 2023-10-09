extends Node
class_name MahjongManager

@onready var gui_manager = $"../GUIManager"
@onready var tile_counter = $TileCounter
@onready var yaku_checker = $YakuChecker


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

enum {STATE_ACTIONABLE, STATE_ANIMATING, STATE_CALLS}
var state = STATE_ACTIONABLE

func _ready():
	await get_tree().process_frame
	
	start_round()

func start_round():
	init_wall()
	
	draw_hand()
	draw_tile()
	
	gui_manager.update_discard([])
	gui_manager.update_opp_discard([])
	
	for i in DEFAULT_KAN_SIZE:
		draw_kan_dora()
	
	gui_manager.update_wall_count(wall.size())

# default tiles
func init_wall():
	wall = tile_counter.get_all_tiles()
	wall.shuffle()
	
	hand.clear()
	tsumo = null
	discard.clear()
	opp_discard.clear()
	kan_dora.clear()
	ura_dora.clear()

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

# stalls gameplay, animating in tiles and also prompting calls
func do_opp_discard():
	state = STATE_ANIMATING
	
	await get_tree().create_timer(.1).timeout
	
	for i in OPPONENT_DISCARDS:
		var disc = wall.pop_back()
		opp_discard.append(disc)
		gui_manager.update_opp_discard(opp_discard)
		gui_manager.update_wall_count(wall.size())
		
#		var call_bitmask = can_cpkr(disc)
#		if call_bitmask != 0:
#			state = STATE_CALLS
#			gui_manager.enable_calls(call_bitmask)
#
#			# stall out as long as `call_graphic_clicked()` hasnt resolved.
#			# this is called by `CallGraphic`s.
#			while state == STATE_CALLS:
#				await get_tree().process_frame
#
		await get_tree().create_timer(.2).timeout
	
	state = STATE_ACTIONABLE

# returns a bitmask for what can be called
enum CALL_BITMASK {
	NONE =		0,
	CHI_L = 	0b100,
	CHI_M = 	0b010,
	CHI_R = 	0b001,
	PON = 		0b1000,
	KAN = 		0b10000,
	RON = 		0b100000,
	TSM = 		0b1000000
}
func can_cpkr(disc: MTile) -> int:
	# ordered rkpccc
	var bitmask = 0b0000
	
	# pon and kan
	var identical_count = 0
	var did = disc.get_id()
	for t in hand:
		if did == t.get_id():
			identical_count += 1
	
	if identical_count >= 2:
		bitmask |= CALL_BITMASK.PON
		if identical_count >= 3:
			bitmask |= CALL_BITMASK.KAN
	
	# chi.
	var adjs = {}
	for i in disc.get_adj_ids(disc.suit, disc.value, true):
		adjs[i] = 0
	
	for t in hand:
		var tid = t.get_id()
		if adjs.keys().has(tid):
			adjs[tid] += 1
	
	if adjs.size() >= 4:
		if adjs[did-2] > 0 and adjs[did-1]:
			bitmask |= CALL_BITMASK.CHI_R
		if adjs[did-1] > 0 and adjs[did+1]:
			bitmask |= CALL_BITMASK.CHI_M
		if adjs[did+1] > 0 and adjs[did+2]:
			bitmask |= CALL_BITMASK.CHI_L
	
	#ron
	var full_hand = [disc]
	full_hand.append_array(hand)
	full_hand.sort()
	if yaku_checker.hand_get_han(full_hand, false, false) > 0:
		bitmask |= CALL_BITMASK.RON
	
	return bitmask

# called when a cpkr call is made, including passing the call
func call_graphic_clicked(bitmask: int):
	state = STATE_ANIMATING


#  for physical buttons. note only tiles we define as
# `clickable` can even be clicked, and since this is only
# for tiles in hand, we know that if a tile is clicked
# it's in hand.
func tile_graphic_clicked(tile: MTile):
	if state == STATE_ACTIONABLE:
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
