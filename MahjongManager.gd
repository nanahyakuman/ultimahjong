extends Node
class_name MahjongManager

@onready var gui_manager = $"../GUIManager"
@onready var tile_counter = $TileCounter
@onready var yaku_checker = $YakuChecker
@onready var calls_manager = $"../GUIManager/Calls"

var OPPONENT_DISCARDS = 3
var DEFAULT_KAN_SIZE = 5

var wall = [] # of `MTile`s
var hand = [] # of `MTile`s
var called_hand = [] # of `grouping`s
var tsumo
var discard = [] # of `MTile`s
var opp_discard = [] # of `MTile`s
var kan_dora = []
var ura_dora = []

enum WINDS {EAST, SOUTH, WEST, NORTH}
var prevalent_wind = -1 # incremented at start of round
var seat_wind = -1

enum {STATE_ACTIONABLE, STATE_ANIMATING, STATE_CALLS}
var state = STATE_ACTIONABLE

func _ready():
	await get_tree().process_frame
	
	start_round()

func start_round():
	increment_winds()
	
	init_wall()
	
	draw_hand()
	draw_tile()
	
	gui_manager.update_discard([])
	gui_manager.update_opp_discard([])
	
	for i in DEFAULT_KAN_SIZE:
		draw_kan_dora()
	
	gui_manager.update_wall_count(wall.size())

func increment_winds():
	seat_wind += 1
	seat_wind %= 4
	if seat_wind == 0:
		prevalent_wind += 1
		prevalent_wind %= 4
	gui_manager.update_winds(prevalent_wind, seat_wind)

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
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
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
		
			#  passed in and updated by `can_cpkr`. easier then
			# retroactively searching for the tiles again (probably).
			#  allows us to quickly highlight and lock off tiles involved
			# in a call. note this is of `MTile,` so we still have to get the
			# relevant tiles in hand manually
		var tiles_involved_in_call = {}
			#  a bitmask for what calls are legal. note chi is split into 3
			# seperate calls depending on shape. this is kinda weird but the
			# involved tiles are highlighted anyway so it shouldn't be that
			# hard to udnerstand
		var call_bitmask = can_cpkr(disc, tiles_involved_in_call)
		if call_bitmask != 0:
			state = STATE_CALLS
			calls_manager.enable_calls(call_bitmask, tiles_involved_in_call)

			# stall out as long as `call_graphic_clicked()` hasnt resolved.
			# this fnctiuon is called by `CallGraphic`s.
			while state == STATE_CALLS:
				await get_tree().process_frame
		
		await get_tree().create_timer(.2).timeout
	
	state = STATE_ACTIONABLE

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
# returns a bitmask for what can be called
func can_cpkr(disc: MTile, tiles_involved: Dictionary) -> int:
	# ordered rkpccc
	var bitmask = 0b0000
	# the dict of involved tiles
	tiles_involved.merge({CALL_BITMASK.CHI_L:[], CALL_BITMASK.CHI_M:[], CALL_BITMASK.CHI_R:[], CALL_BITMASK.PON:[], CALL_BITMASK.KAN:[]})
	# (only functional for pons and kans atm)
	
	# pon and kan
	var identical_count = 0
	var did = disc.get_id()
	for t in hand:
		var tid = t.get_id()
		if did == tid:
			identical_count += 1
			tiles_involved[CALL_BITMASK.PON].append(t)
			tiles_involved[CALL_BITMASK.KAN].append(t)
	
	if identical_count >= 2:
		bitmask |= CALL_BITMASK.PON
		if identical_count >= 3:
			bitmask |= CALL_BITMASK.KAN
			tiles_involved[CALL_BITMASK.PON].resize(2)
			tiles_involved[CALL_BITMASK.KAN].resize(3)
		else:
			tiles_involved[CALL_BITMASK.KAN].clear()
	else:
		tiles_involved[CALL_BITMASK.PON].clear()
		tiles_involved[CALL_BITMASK.KAN].clear()
	
	
	# chi.
	var adjs = {}
	for i in disc.get_adj_ids(disc.suit, disc.value, true):
		adjs[i] = 0
	
	for t in hand:
		var tid = t.get_id()
		var extant = adjs.keys().find(tid)
		if extant != -1:
			adjs[tid] += 1
			
			if extant == 0:
				tiles_involved[CALL_BITMASK.CHI_R].append(t)
			elif extant == 1:
				tiles_involved[CALL_BITMASK.CHI_R].append(t)
				tiles_involved[CALL_BITMASK.CHI_M].append(t)
			elif extant == 2:
				tiles_involved[CALL_BITMASK.CHI_M].append(t)
				tiles_involved[CALL_BITMASK.CHI_L].append(t)
			else:
				tiles_involved[CALL_BITMASK.CHI_L].append(t)
	
	if adjs.size() >= 4:
		if adjs[did-2] > 0 and adjs[did-1]:
			bitmask |= CALL_BITMASK.CHI_R
		else:
			tiles_involved[CALL_BITMASK.CHI_R].clear()
		if adjs[did-1] > 0 and adjs[did+1]:
			bitmask |= CALL_BITMASK.CHI_M
		else:
			tiles_involved[CALL_BITMASK.CHI_M].clear()
		if adjs[did+1] > 0 and adjs[did+2]:
			bitmask |= CALL_BITMASK.CHI_L
		else:
			tiles_involved[CALL_BITMASK.CHI_L].clear()
	else:
		tiles_involved[CALL_BITMASK.CHI_R].clear()
		tiles_involved[CALL_BITMASK.CHI_M].clear()
		tiles_involved[CALL_BITMASK.CHI_L].clear()
	
	
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

# right click to close call menu
func _input(event):
	if state == STATE_CALLS:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				call_graphic_clicked(CALL_BITMASK.NONE)
				calls_manager.enable_calls(0, {})
	
#	if event is InputEventMouseButton:
#		increment_winds()


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
