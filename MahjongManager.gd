##  if you set the state to ANIMATING, nothing is allowed to happen. this
## allows us to chain awaits to make cheap anims.
extends Node
class_name MahjongManager

@onready var gui_manager = $"../GUIManager"
@onready var tile_counter = $TileCounter
@onready var yaku_checker = $YakuChecker
@onready var calls_manager = $"../GUIManager/Calls"
@onready var tile_sfx_player = $TileOnTable
@onready var call_sfx_player = $CallMade
@onready var root = $"../../.."
@onready var anim_timer = $AnimTimer

# how many discards inbetween each player draw
var OPPONENT_DISCARDS = 3
# how many kan tiles to draw
var KAN_SIZE = 5
# base size of the hand
var BASE_HAND_SIZE = 13
#  amount of tiles to kill at the start. (it's the present value * 3).
# this should be an even number or the dead wall display will break
var TILES_DEAD_PER_4_PLAYER_DRAWS = 12

var wall = [] # of `MTile`s
var hand = [] # of `MTile`s
var called_hand = [] # of `grouping`s
var tsumo # a Mtile or null. it's very important that this remains null when
# it's not active, ctrl-f "tsumo" to see.
var discard = [] # of `MTile`s
var opp_discard = [] # of `MTile`s
var kan_dora = []
var ura_dora = []
var revealed_kan_dora = 1

enum WINDS {EAST, SOUTH, WEST, NORTH}
var prevalent_wind = -1 
var seat_wind = -3 # incremented at start of round

enum {STATE_ACTIONABLE, STATE_ANIMATING, STATE_CALLS}
var state = STATE_ANIMATING
#  i dont like this being global but its the easist way to make
# this work
var remaining_opp_discards


func start_round():
	gui_manager.update_discard([])
	gui_manager.update_tsumo([])
	gui_manager.update_opp_discard([])
	gui_manager.update_made_calls([])
	gui_manager.update_kan_dora([],0)
	gui_manager.update_hand([])
	gui_manager.reset_dead_wall_count()
	gui_manager.update_wall_count(0)
	
	increment_winds()
	
	await init_wall()
	
	await anim_timer.start_mod(.15).timeout
	
	for i in KAN_SIZE:
		await anim_timer.start_mod(.1).timeout
		tile_sfx_player.play()
		draw_kan_dora()
	
	await anim_timer.start_mod(.15).timeout
	
	await draw_hand()
	
	start_rotation(seat_wind)

func increment_winds():
	seat_wind += 3
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
	called_hand.clear()
	
	for i in wall.size():
		await anim_timer.start_get(.01).timeout
		gui_manager.update_wall_count(i+1)
		tile_sfx_player.play()
	

func draw_hand():
	# the chaining looks dopey but it lets us draw by sets of 
	# 4 (admittedly mostly for effect).
	for i in int(BASE_HAND_SIZE/4):
		await anim_timer.start_mod(.15).timeout
		hand.append(get_next_from_wall())
		hand.append(get_next_from_wall())
		hand.append(get_next_from_wall())
		hand.append(get_next_from_wall())
		call_sfx_player.play()
		update_hand_label()
		for j in TILES_DEAD_PER_4_PLAYER_DRAWS/4:
			await anim_timer.start_mod(.15).timeout
			get_next_from_wall()
			get_next_from_wall()
			get_next_from_wall()
			get_next_from_wall()
			gui_manager.increment_dead_wall_count(4)
			call_sfx_player.play()
		if TILES_DEAD_PER_4_PLAYER_DRAWS%4 != 0:
			await anim_timer.start_mod(.15).timeout
			for j in TILES_DEAD_PER_4_PLAYER_DRAWS%4:
				get_next_from_wall()
			gui_manager.increment_dead_wall_count(TILES_DEAD_PER_4_PLAYER_DRAWS%4)
			call_sfx_player.play()
		
	for i in BASE_HAND_SIZE%4:
		await anim_timer.start_mod(.15).timeout
		hand.append(get_next_from_wall())
		tile_sfx_player.play()
		update_hand_label()
	
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HATSU))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HATSU))
#	hand.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HATSU))
#	hand.append(MTile.new(MTile.SUITS.MAN, 2))
#	hand.append(MTile.new(MTile.SUITS.MAN, 2))
#	hand.append(MTile.new(MTile.SUITS.MAN, 1))
#	hand.append(MTile.new(MTile.SUITS.MAN, 1))
#	var temp = []
#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2, true))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.MAN, 4))
#	temp.append(MTile.new(MTile.SUITS.MAN, 5, true))
#	temp.append(MTile.new(MTile.SUITS.MAN, 6))
#	temp.append(MTile.new(MTile.SUITS.MAN, 7))
#	temp.append(MTile.new(MTile.SUITS.MAN, 8))
#	temp.append(MTile.new(MTile.SUITS.MAN, 9))
#	temp.append(MTile.new(MTile.SUITS.MAN, 9, true))
#	temp.append(MTile.new(MTile.SUITS.MAN, 9))
#	hand = temp
#	update_hand_label()
	

func draw_kan_dora():
	kan_dora.append(get_next_from_wall())
	ura_dora.append(get_next_from_wall())
	gui_manager.update_kan_dora(kan_dora, KAN_SIZE - revealed_kan_dora)
	
	var revealed_dora_ids = []
	for i in range(KAN_SIZE-revealed_kan_dora, kan_dora.size()):
		for id in kan_dora[i].get_dora_id():
			revealed_dora_ids.append(id)
	TileGraphicKnower.update_dora_ids(revealed_dora_ids)


##  this is dopey but `start_rotation` calls `do_opp_discard`,
## which recursively calls either itself or `do_tsumo` or "do_post_call_discard`
## depending on if calls are made.
func start_rotation(discard_override = null):
	remaining_opp_discards = discard_override if discard_override != null else OPPONENT_DISCARDS
	do_opp_discard()

func do_tsumo():
	state = STATE_ACTIONABLE
	tsumo = get_next_from_wall()
#	tsumo = MTile.new(MTile.SUITS.MAN, 1)
	if !tsumo:
		return
	gui_manager.update_tsumo([tsumo])
	tile_sfx_player.play()
	
	# tsumo agari
	do_if_can_tsumo()


func do_post_call_discard():
	state = STATE_ACTIONABLE


#  discard 1 tile, prompt calls if appropriate, recurse/go to player
# draw if not
func do_opp_discard():
	state = STATE_ANIMATING
	await anim_timer.start_mod(.2).timeout
	
	if remaining_opp_discards == 0:
		do_tsumo()
		return
	remaining_opp_discards -= 1
	
	
	var disc = get_next_from_wall()
	if !disc:
		return
	opp_discard.append(disc)
	gui_manager.update_opp_discard(opp_discard)
	
	tile_sfx_player.play()
	
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
		#  switching state like this means that only calls are taken as 
		# input
		state = STATE_CALLS
		calls_manager.enable_calls(call_bitmask, tiles_involved_in_call)
	else:
		do_opp_discard()
	

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
	
	
	# chi. only callable on last discard in cycle
	if remaining_opp_discards == 0:
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
	
	#  erase redundant entries in a chi. i hate to triplicate code but something
	# about putting this in a loop breaks it. i think godot tries to intuitively
	# concatenate array arrays or sumn.
	var a = tiles_involved[CALL_BITMASK.CHI_R]
	var marked = {}
	for t in a:
		var tid = t.get_id()
		var count = count_by_id(tid, a)
		if count > 1:
			marked[tid] = count - 1
	for m in marked.keys():
		for i in marked[m]:
			var tbd = first_by_id(m, a)
			a.remove_at(tbd)
	
	a = tiles_involved[CALL_BITMASK.CHI_M]
	marked = {}
	for t in a:
		var tid = t.get_id()
		var count = count_by_id(tid, a)
		if count > 1:
			marked[tid] = count - 1
	for m in marked.keys():
		for i in marked[m]:
			var tbd = first_by_id(m, a)
			a.remove_at(tbd)
	
	a = tiles_involved[CALL_BITMASK.CHI_L]
	marked = {}
	for t in a:
		var tid = t.get_id()
		var count = count_by_id(tid, a)
		if count > 1:
			marked[tid] = count - 1
	for m in marked.keys():
		for i in marked[m]:
			var tbd = first_by_id(m, a)
			a.remove_at(tbd)
	
	
	#ron
	var full_hand = [disc]
	full_hand.append_array(hand)
	full_hand.sort()
	if yaku_checker.hand_get_han(full_hand, called_hand, false).get_total_han() > 0:
		bitmask |= CALL_BITMASK.RON
	
	return bitmask

# check if can tsumo, prompt if so
func do_if_can_tsumo():
	var full_hand = [tsumo]
	full_hand.append_array(hand)
	full_hand.sort()
	if yaku_checker.hand_get_han(full_hand, called_hand, true).get_total_han() > 0:
		state = STATE_CALLS
		calls_manager.enable_calls(CALL_BITMASK.TSM, {})


# called when a cpkr call is made, including passing the call
func call_graphic_clicked(bitmask: int, tiles_involved: Array):
	assert(state == STATE_CALLS, "call somehow made in non-calling state. this is bad!")
	
	var new_grouping
	match bitmask:
		CALL_BITMASK.NONE:
			#  if were cancelling tsumo, just continue play,
			# else continue discarding
			if tsumo != null:
				state = STATE_ACTIONABLE
			else:
				do_opp_discard()
			return
		CALL_BITMASK.TSM:
			end_round(true)
		CALL_BITMASK.RON:
			end_round()
		CALL_BITMASK.CHI_L:
			new_grouping = Grouping.new(Grouping.RUN, tiles_involved)
		CALL_BITMASK.CHI_M:
			new_grouping = Grouping.new(Grouping.RUN, tiles_involved)
		CALL_BITMASK.CHI_R:
			new_grouping = Grouping.new(Grouping.RUN, tiles_involved)
		CALL_BITMASK.PON:
			new_grouping = Grouping.new(Grouping.SET, tiles_involved)
		CALL_BITMASK.KAN:
			new_grouping = Grouping.new(Grouping.SET, tiles_involved)
	
	if new_grouping is Grouping:
		for t in new_grouping.tiles:
			var found = first_by_id(t.get_id(), hand)
			assert(found != -1, "could not find tile that's meant to exist in hand!")
			hand.remove_at(found)
		
		new_grouping.tiles.append(opp_discard.pop_back())
		new_grouping.tiles.sort_custom(Callable(MTile, "tile_compare"))
		new_grouping.open = true
		called_hand = [new_grouping] + called_hand
		gui_manager.update_opp_discard(opp_discard)
		gui_manager.update_hand(hand)
		gui_manager.update_made_calls(called_hand)
	
	
	call_sfx_player.play()
	if bitmask == CALL_BITMASK.KAN:
		do_tsumo()
	else:
		do_post_call_discard()

# right click to close call menu
func _input(event):
	if state == STATE_CALLS:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				call_graphic_clicked(CALL_BITMASK.NONE, [])
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

#  if there is a tsumo, we must be drawing.
# if not, we must just be discarding afer a call
func draw_and_discard(discardee: MTile):
	if tsumo:
		hand.append(tsumo)
		tsumo = null
	hand.erase(discardee)
	discard.append(discardee)
	update_hand_label()
	gui_manager.update_discard(discard)
	gui_manager.update_tsumo([])
	
	tile_sfx_player.play()
	
	TileGraphicKnower.highlight_matching_tiles(discardee, false)
	start_rotation()

func update_hand_label():
	hand.sort_custom(Callable(MTile, "tile_compare"))
	gui_manager.update_hand(hand)


func get_next_from_wall():
	if wall.size() == 0:
		end_round()
		return null
	var ret = wall.pop_back()
	gui_manager.update_wall_count(wall.size())
	return ret


func end_round(win_is_tsumo_not_ron = false):
	# dora and uradora ids.
	var omote_doras = []
	var ura_doras = []
#	for t in revealed_kan_dora:
#		doras.append(kan_dora[-t].get_dora_id())
#	if called_hand.size() == 0:
#		for t in revealed_kan_dora:
#			doras.append(ura_dora[-t].get_dora_id())
	for i in range(KAN_SIZE-revealed_kan_dora, kan_dora.size()):
		for id in kan_dora[i].get_dora_id():
			omote_doras.append(id)
	if hand_is_open:
		for i in range(KAN_SIZE-revealed_kan_dora, kan_dora.size()):
			for id in ura_dora[i].get_dora_id():
				ura_doras.append(id)
	var doras = [omote_doras, ura_doras]
	
	# attach winning tile to hand
	var full_hand = hand.duplicate()
	if win_is_tsumo_not_ron:
		full_hand.append(tsumo)
	else:
		full_hand.append(opp_discard.back())
	full_hand.sort()
	
	#  must have 14 tiles. this might need to be changed later
	# for bigger hands
	assert(full_hand.size() + called_hand.size() * 3 == 14)
	
	var score_info = yaku_checker.hand_get_han(full_hand, called_hand, win_is_tsumo_not_ron, doras, true)
	
	var multiplier = 6 if seat_wind == WINDS.EAST else 4
	
	#print("%d  %d  %d" % [fu, han, multiplier])
	root.end_round(score_info, multiplier)
	
	# moved to root temporarily(?)
	#TileGraphicKnower.update_dora_ids([])


func hand_is_open():
	return called_hand.size() > 0


func first_by_id(id: int, tiles: Array) -> int:
	for t in tiles.size():
		if tiles[t].get_id() == id:
			return t
	return -1
func count_by_id(id: int, tiles: Array) -> int:
	var count = 0
	for t in tiles.size():
		if tiles[t].get_id() == id:
			count += 1
	return count
