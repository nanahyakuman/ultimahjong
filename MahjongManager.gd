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
@onready var anim_timer = $%AnimTimer
@onready var upgrades = $Upgrades
@onready var hand_gui = $"../GUIManager/All/SideSpacers/Tiles/HBoxContainer/Hand"
@onready var ALL_YAKU = $YakuFu
# gui holds these guys, it's gross but probably easier overall
@onready var items = %Items

# base size of the hand
const BASE_HAND_SIZE = 13

var character_info = null

var wall = [] # of `MTile`s
var dead_wall = [] # of `MTile`s
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
var seat_wind = 0 # incremented at start of round

enum {STATE_ACTIONABLE, STATE_ANIMATING, STATE_CALLS, STATE_SELECT_TILE}
# use `set_state` onegaishimasu
var _state = STATE_ANIMATING
#  i dont like this being global but its the easist way to make
# this work
var remaining_opp_discards

# trackers for yaku it makes sense for `MahjongManager` to handle
var in_riichi = false
var ippatsu_counter = 0
var was_last_draw_from_dead_wall = false

var met_yaku: ScoringInfo

#  a node that requests for a tile from the hand(+tsumo) to be selected
var tile_select_requestor_node = null
var remove_from_hand_on_selection = null

func initialize(ch: CharacterInfo):
	character_info = ch
	tile_counter.initialize(character_info)
	upgrades.initialize(character_info)

func start_round():
	gui_manager.update_discard([])
	gui_manager.update_tsumo([])
	gui_manager.update_opp_discard([])
	gui_manager.update_made_calls([])
	gui_manager.update_kan_dora([],0)
	gui_manager.update_hand([])
	gui_manager.reset_dead_wall_count()
	gui_manager.update_wall_count(0)
	calls_manager.enable_calls(0, {})
	
	in_riichi = false
	
	met_yaku = ScoringInfo.new()
	
	_increment_winds()
	
	
	await _init_wall()
	
	await anim_timer.start_mod(.15)
	
	for i in upgrades.get_kan_size():
		await anim_timer.start_mod(.1)
		tile_sfx_player.play()
		_draw_kan_dora()
	
	await anim_timer.start_mod(.15)
	
	await _draw_hand()
	
	_start_rotation(seat_wind)
	
	MusicManager.start_round()
	

func _increment_winds():
	# because modding negative numbers doesnt work right
	seat_wind += character_info.valid_seats-1
	seat_wind %= character_info.valid_seats
	if seat_wind == character_info.valid_seats-1:
		prevalent_wind += 1
		prevalent_wind %= 4
		MusicManager.queue_next_song()
	gui_manager.update_winds(prevalent_wind, seat_wind)

# default tiles
func _init_wall():
	wall = tile_counter.get_all_tiles()
	wall.shuffle()
	
	hand.clear()
	tsumo = null
	discard.clear()
	opp_discard.clear()
	kan_dora.clear()
	ura_dora.clear()
	called_hand.clear()
	
	for i in range(0, wall.size(), 6):
		await anim_timer.start_mod(.04)
		gui_manager.update_wall_count(i)
		call_sfx_player.play()
	gui_manager.update_wall_count(wall.size())
	

func _draw_hand():
	for j in upgrades.get_dead_tiles()/4:
		await anim_timer.start_mod(.15)
		for k in 4:
			dead_wall.append(_get_next_from_wall(true))
		gui_manager.increment_dead_wall_count(4)
		call_sfx_player.play()
	
	if upgrades.get_dead_tiles()%4 != 0:
		await anim_timer.start_mod(.15)
		for j in upgrades.get_dead_tiles()%4:
			dead_wall.append(_get_next_from_wall(true))
		gui_manager.increment_dead_wall_count(upgrades.get_dead_tiles()%4)
		call_sfx_player.play()
	
	await anim_timer.start_mod(.15)
	
	for i in BASE_HAND_SIZE:
		await anim_timer.start_mod(.07)
		hand.append(_get_next_from_wall(true))
		call_sfx_player.play()
		update_hand_label(true)
	
	await anim_timer.start_mod(.15)
	call_sfx_player.play()
	update_hand_label()
	
	var temp = []
#
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.EAST))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.EAST))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))

#	temp.append(MTile.new(MTile.SUITS.SOU, 1))
#	temp.append(MTile.new(MTile.SUITS.SOU, 1))
#	temp.append(MTile.new(MTile.SUITS.SOU, 1))
#	temp.append(MTile.new(MTile.SUITS.SOU, 2))
#	temp.append(MTile.new(MTile.SUITS.SOU, 3))
#	temp.append(MTile.new(MTile.SUITS.SOU, 4))
#	temp.append(MTile.new(MTile.SUITS.SOU, 5))
#	temp.append(MTile.new(MTile.SUITS.SOU, 6))
#	temp.append(MTile.new(MTile.SUITS.SOU, 7))
#	temp.append(MTile.new(MTile.SUITS.SOU, 8))
#	temp.append(MTile.new(MTile.SUITS.SOU, 9))
#	temp.append(MTile.new(MTile.SUITS.SOU, 9))
#	temp.append(MTile.new(MTile.SUITS.SOU, 9))
#
#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HATSU))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HATSU))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HATSU))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))

#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 4))
#	temp.append(MTile.new(MTile.SUITS.MAN, 4))
#	temp.append(MTile.new(MTile.SUITS.MAN, 6))
#	temp.append(MTile.new(MTile.SUITS.MAN, 6))
#	temp.append(MTile.new(MTile.SUITS.PIN, 8))
#	temp.append(MTile.new(MTile.SUITS.PIN, 8))
#	temp.append(MTile.new(MTile.SUITS.PIN, 4))
#	temp.append(MTile.new(MTile.SUITS.PIN, 4))
#	temp.append(MTile.new(MTile.SUITS.PIN, 2))
#	temp.append(MTile.new(MTile.SUITS.PIN, 2))

#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.MAN, 4))
#
#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.MAN, 4))
#	temp.append(MTile.new(MTile.SUITS.MAN, 5))
#	temp.append(MTile.new(MTile.SUITS.MAN, 6))
#	temp.append(MTile.new(MTile.SUITS.MAN, 7))
#	temp.append(MTile.new(MTile.SUITS.MAN, 8))
#	temp.append(MTile.new(MTile.SUITS.MAN, 9))
#	temp.append(MTile.new(MTile.SUITS.SOU, 1))
#	temp.append(MTile.new(MTile.SUITS.SOU, 1))
#	temp.append(MTile.new(MTile.SUITS.SOU, 9))
#	temp.append(MTile.new(MTile.SUITS.SOU, 9))

#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.PIN, 1))
#	temp.append(MTile.new(MTile.SUITS.PIN, 2))
#	temp.append(MTile.new(MTile.SUITS.PIN, 3))
#	temp.append(MTile.new(MTile.SUITS.SOU, 1))
#	temp.append(MTile.new(MTile.SUITS.SOU, 2))
#	temp.append(MTile.new(MTile.SUITS.SOU, 3))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HATSU))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HATSU))

#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.PIN, 1))
#	temp.append(MTile.new(MTile.SUITS.PIN, 2))
#	temp.append(MTile.new(MTile.SUITS.PIN, 3))
#	temp.append(MTile.new(MTile.SUITS.SOU, 2))
#	temp.append(MTile.new(MTile.SUITS.SOU, 3))
#	temp.append(MTile.new(MTile.SUITS.SOU, 4))
#	temp.append(MTile.new(MTile.SUITS.SOU, 4))
#	temp.append(MTile.new(MTile.SUITS.SOU, 5))
#	temp.append(MTile.new(MTile.SUITS.SOU, 9))
#	temp.append(MTile.new(MTile.SUITS.SOU, 9))

#	temp.append(MTile.new(MTile.SUITS.SOU, 9))
#	temp.append(MTile.new(MTile.SUITS.SOU, 9))
#	temp.append(MTile.new(MTile.SUITS.SOU, 9))
#	temp.append(MTile.new(MTile.SUITS.MAN, 9))
#	temp.append(MTile.new(MTile.SUITS.MAN, 9))
#	temp.append(MTile.new(MTile.SUITS.MAN, 9))
#	temp.append(MTile.new(MTile.SUITS.PIN, 9))
#	temp.append(MTile.new(MTile.SUITS.PIN, 9))
#	temp.append(MTile.new(MTile.SUITS.PIN, 9))
#	temp.append(MTile.new(MTile.SUITS.MAN, 1))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.SOU, 1))

#	temp.append(MTile.new(MTile.SUITS.SOU, 1))
#	temp.append(MTile.new(MTile.SUITS.SOU, 2))
#	temp.append(MTile.new(MTile.SUITS.SOU, 3))
#	temp.append(MTile.new(MTile.SUITS.SOU, 2))
#	temp.append(MTile.new(MTile.SUITS.SOU, 3))
#	temp.append(MTile.new(MTile.SUITS.SOU, 4))
#	temp.append(MTile.new(MTile.SUITS.MAN, 2))
#	temp.append(MTile.new(MTile.SUITS.MAN, 3))
#	temp.append(MTile.new(MTile.SUITS.MAN, 4))
#	temp.append(MTile.new(MTile.SUITS.MAN, 9))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.WEST))
#	temp.append(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.WEST))
#	temp.append(MTile.new(MTile.SUITS.FLOWER, 1))
	

	if temp:
		assert(temp.size() == 13)
		temp.sort()
		hand = temp
	update_hand_label()
	

func _draw_kan_dora():
	kan_dora.append(_get_next_from_wall(true))
	ura_dora.append(_get_next_from_wall(true))
	
	revealed_kan_dora = upgrades.get_kan_revealed()
	
	update_revealed_kan_dora()

func _reveal_dora():
	revealed_kan_dora += 1
	
	update_revealed_kan_dora()

# used by an item
func get_and_overwrite_most_recent_kan_dora(tile: MTile) -> MTile:
	var ret = kan_dora[upgrades.get_kan_size() - revealed_kan_dora]
	kan_dora[upgrades.get_kan_size() - revealed_kan_dora] = tile
	
	update_revealed_kan_dora()
	
	return ret

func update_revealed_kan_dora():
	gui_manager.update_kan_dora(kan_dora, upgrades.get_kan_size() - revealed_kan_dora)
	
	var revealed_dora_ids = []
	for i in range(upgrades.get_kan_size() - revealed_kan_dora, kan_dora.size()):
		for id in kan_dora[i].get_dora_id():
			revealed_dora_ids.append(id)
	TileGraphicKnower.update_dora_ids(revealed_dora_ids)

##  this is dopey but `start_rotation` calls `do_opp_discard`,
## which recursively calls either itself or `do_tsumo` or "do_post_call_discard`
## depending on if calls are made.
func _start_rotation(discard_override = null):
	_assign_discard_count(discard_override)
	_do_opp_discard()

# awkward to split this one line into own function but entering riicihi also needs it
func _assign_discard_count(discard_override = null):
	remaining_opp_discards = discard_override if discard_override != null else upgrades.get_discard_count()

# occasionally called by items that override the present tsumo tile
func do_tsumo(override: MTile = null):
	assert(tsumo == null, "Overriding an existing tsumo! Set it to null first if this is intended.")
	
	if override:
		tsumo = override
	else:
		tsumo = _get_next_from_wall()
	if !tsumo:
		return
	
	gui_manager.update_tsumo([tsumo])
	tile_sfx_player.play()
	
	_set_state(STATE_ACTIONABLE)
	
	# tsumo agari, also kan check
	_do_if_can_tsumo()


func _do_post_call_discard():
	_set_state(STATE_ACTIONABLE)


#  discard 1 tile, prompt calls if appropriate, recurse/go to player
# draw if not
func _do_opp_discard():
	_set_state(STATE_ANIMATING)
	await anim_timer.start_mod(.2)
	
	if remaining_opp_discards == 0:
		do_tsumo()
		return
	remaining_opp_discards -= 1
	
	
	var disc = _get_next_from_wall()
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
	var call_bitmask = _can_cpkr(disc, tiles_involved_in_call)
	if call_bitmask != 0:
		#  switching state like this means that only calls are taken as 
		# input
		calls_manager.enable_calls(call_bitmask, tiles_involved_in_call)
		_set_state(STATE_CALLS)
	else:
		_do_opp_discard()
	

enum CALL_BITMASK {
	NONE =		0,
	CHI_L = 	0b100,
	CHI_M = 	0b010,
	CHI_R = 	0b001,
	PON = 		0b1000,
	KAN = 		0b10000,
	RON = 		0b100000,
	TSM = 		0b1000000,
	CLOSED_KAN= 0b10000000,
	RCH =		0b100000000,
	FLOWER =	0b1000000000
}
# returns a bitmask for what can be called
func _can_cpkr(disc: MTile, tiles_involved: Dictionary) -> int:
	# ordered rkpccc
	var bitmask = 0b0000
	
	#ron check
	var scoring_info = yaku_checker.hand_get_han(get_hand_info(), [], false, met_yaku)
	if scoring_info.get_total_han() > 0:
		bitmask |= CALL_BITMASK.RON
	
	# the rest only apply if not in riichi
	if in_riichi:
		return bitmask
	
	
	# the dict of involved tiles is passed by ref.
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
	
	
	# chi. only callable on last discard in cycle unless upgraded
	if remaining_opp_discards < upgrades.get_legal_chis():
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
		var count = MahjongManager.count_by_id(tid, a)
		if count > 1:
			marked[tid] = count - 1
	for m in marked.keys():
		for i in marked[m]:
			var tbd = MahjongManager.first_by_id(m, a)
			a.remove_at(tbd)
	
	a = tiles_involved[CALL_BITMASK.CHI_M]
	marked = {}
	for t in a:
		var tid = t.get_id()
		var count = MahjongManager.count_by_id(tid, a)
		if count > 1:
			marked[tid] = count - 1
	for m in marked.keys():
		for i in marked[m]:
			var tbd = MahjongManager.first_by_id(m, a)
			a.remove_at(tbd)
	
	a = tiles_involved[CALL_BITMASK.CHI_L]
	marked = {}
	for t in a:
		var tid = t.get_id()
		var count = MahjongManager.count_by_id(tid, a)
		if count > 1:
			marked[tid] = count - 1
	for m in marked.keys():
		for i in marked[m]:
			var tbd = MahjongManager.first_by_id(m, a)
			a.remove_at(tbd)
	
	return bitmask

# check if can tsumo agari, kan, flower, etc/
func _do_if_can_tsumo():
	var full_hand = [tsumo]
	full_hand.append_array(hand)
	full_hand.sort_custom(Callable(MTile, "tile_compare"))
	
	var btm = 0
	var involved = {}
	
	if yaku_checker.hand_get_han(get_hand_info(), [], false, null).get_total_han() > 0:
		btm |= CALL_BITMASK.TSM
	
	# closed tsumo kan. note we ban riichi kans
	if !in_riichi:
		var tsid = tsumo.get_id()
		var kantiles = []
		for t in hand:
			if t.get_id() == tsid:
				kantiles.append(t)
		if kantiles.size() >= 3:
			btm |= CALL_BITMASK.CLOSED_KAN
			# append involved tiles
			var firstthree = []
			for i in 3:
				firstthree.append(kantiles[i])
			involved[CALL_BITMASK.CLOSED_KAN] = firstthree
	
	#flowers:
	for t in full_hand:
		if t.suit == MTile.SUITS.FLOWER:
			btm |= CALL_BITMASK.FLOWER
			involved[CALL_BITMASK.FLOWER] = [t]
			break
	
	if btm:
		calls_manager.enable_calls(btm, involved)
		_set_state(STATE_CALLS)


# called when a cpkr call is made, including passing the call
func call_graphic_clicked(bitmask: int, _tiles_involved: Array):
	assert(_state == STATE_CALLS, "call somehow made in non-calling state. this is bad!")
	
	# clear gui but dont let it delete the info referenced
	var tiles_involved = _tiles_involved.duplicate()
	calls_manager.enable_calls(0, {})
	
	var new_grouping
	match bitmask:
		CALL_BITMASK.NONE:
			#  if were cancelling tsumo, just continue play,
			# else continue discarding
			if tsumo != null:
				_set_state(STATE_ACTIONABLE)
			else:
				_do_opp_discard()
			return
		CALL_BITMASK.TSM:
			_end_round(true)
			return
		CALL_BITMASK.RON:
			_end_round()
			return
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
			_reveal_dora()
		CALL_BITMASK.CLOSED_KAN:
			new_grouping = Grouping.new(Grouping.SET, tiles_involved)
		CALL_BITMASK.FLOWER:
			new_grouping = Grouping.new(Grouping.SPECIAL, tiles_involved)
		CALL_BITMASK.RCH:
			_do_riichi()
			return
	
	if new_grouping is Grouping:
		var to_remove = new_grouping.tiles.size()
		for t in new_grouping.tiles:
			if tsumo == t:
				tsumo = null
				gui_manager.update_tsumo([])
				to_remove -= 1
				continue
			var found = first_by_id(t.get_id(), hand)
			assert(found != -1, "could not find tile that's meant to exist in hand!")
			hand.remove_at(found)
			to_remove -= 1
		assert(to_remove == 0, "not as many tiles as expected removed from hand!")
		
		# append final tile
		if bitmask == CALL_BITMASK.CLOSED_KAN:
			new_grouping.tiles.append(tsumo)
		elif  bitmask == CALL_BITMASK.FLOWER:
			pass
		else:
			new_grouping.tiles.append(opp_discard.pop_back())
		new_grouping.tiles.sort_custom(Callable(MTile, "tile_compare"))
		
		# closed kan stay closed
		if ![CALL_BITMASK.CLOSED_KAN, CALL_BITMASK.FLOWER].has(bitmask):
			new_grouping.open_tile = 0
			new_grouping.player_taken_from_offset = remaining_opp_discards
		called_hand = [new_grouping] + called_hand
		gui_manager.update_made_calls(called_hand)
		
		gui_manager.update_opp_discard(opp_discard)
		update_hand_label()
		gui_manager.update_tsumo([])
	
	
	call_sfx_player.play()
	if [CALL_BITMASK.FLOWER, CALL_BITMASK.KAN, CALL_BITMASK.CLOSED_KAN].has(bitmask):
		# tiles you spawn with can subvert the current tsumo
		if tsumo:
			hand.append(tsumo)
			tsumo = null
			update_hand_label()
			# redundant to clear bc we just draw another
			#gui_manager.update_tsumo([])
		was_last_draw_from_dead_wall = true
		do_tsumo(dead_wall.pop_back())
	else:
		_do_post_call_discard()

# right click to close call menu, cancel item use
func _input(event):
	if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				if _state == STATE_CALLS:
					call_graphic_clicked(CALL_BITMASK.NONE, [])
				elif _state == STATE_SELECT_TILE:
					tile_select_requestor_node.cancel_selection()
					complete_tile_select()
	
#	if event is InputEventMouseButton:
#		increment_winds()


#  for physical buttons. note only tiles we define as
# in_hand` can even be clicked, and since this is only
# for tiles in hand, we know that if a tile is clicked
# it's in hand.
func tile_graphic_clicked(tile: MTile):
	if _state == STATE_ACTIONABLE:
		was_last_draw_from_dead_wall = false
		if in_riichi:
			_draw_and_discard(tsumo)
		else:
			_draw_and_discard(tile)
	elif _state == STATE_SELECT_TILE:
		if !tile_select_requestor_node.tile_valid(tile):
			return
		
		if remove_from_hand_on_selection:
			if tsumo == tile:
				tsumo = null
			else:
				# prevent from making any modifications to a riichi hand
				if in_riichi:
					return
				else:
					hand.erase(tile)
		
		_set_state(STATE_ANIMATING)
		tile_select_requestor_node.tile_selected(tile)
		

#func draw_and_discard_index(i: int):
#	if i == 13:
#		draw_and_discard(tsumo)
#	else:
#		draw_and_discard(hand[i])

#  if there is a tsumo, we must be drawing.
# if not, we must just be discarding afer a call
func _draw_and_discard(discardee: MTile):
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
	
	if !_try_enter_riichi():
		_start_rotation()

#  for calling externally. assumes that a tile has already been cleared from the
# hand somehow.
func add_to_hand_and_update(tile: MTile):
	if tsumo == null:
		tsumo = tile
	else:
		hand.append(tile)
	assert(hand.size() + int(tsumo != null) + get_called_hand_size() == 14, "hand size messed up!")
	update_hand_label()
	gui_manager.update_tsumo([tsumo])
	
	_do_if_can_tsumo()

#  easy function to take an array of valid tiles ids, search the wall for them,
# and replace our next theoretical tsumo with the first one we find.
#  used by items
func swap_in_next_theoretical_tsumo(valid_tile_ids: Array):
	# need to be able to draw
	if wall.size() < upgrades.get_discard_count():
		return
	
	var found_valids = []
	for i in wall.size():
		var t = wall[i]
		if valid_tile_ids.has(t.get_id()):
				found_valids.append(i)
	
	#  select a random valid tile from the deck and swap it
	# for the next draw from the deck
	if found_valids.size() != 0:
		var index = found_valids[randi()%found_valids.size()]
		var valid = wall[index]
		
		#  swap selected valid with next tsumo, preventing us from reshuffling
		# the whole deck
		_switch_tile_with_tsumo(valid, index)

#  you don't need to provide an index but it saves us a `.find()`
# if you do. `tile` should be a ref to a tile literally in the
# deck or this won't work.
func _switch_tile_with_tsumo(tile: MTile, index: int = -1):
	if index < 0:
		index = wall.find(tile)
	assert(index >= 0, "trying to switch with a tile that doesn't exist in the deck!")
	
	var switch = wall[-upgrades.get_discard_count()-1]
	wall[-upgrades.get_discard_count()-1] = tile
	wall[index] = switch


func _try_enter_riichi():
	if in_riichi or hand_is_open() or wall.size() < 4:
		return false
	for t in tile_counter.get_all_tiles():
		var full_hand = [t]
		full_hand.append_array(hand)
		# this is safe because we assert that the hand is closed
		full_hand.sort_custom(Callable(MTile, "tile_compare"))
		if yaku_checker.hand_meets_basic_reqs(full_hand, called_hand):
			calls_manager.enable_calls(CALL_BITMASK.RCH, {})
			_set_state(STATE_CALLS)
			_assign_discard_count()
			return true
	return false

# entered from calls
func _do_riichi():
	in_riichi = true
	ippatsu_counter = upgrades.get_discard_count() + 1
	if discard.size() == 1:
		met_yaku.hans.append(ALL_YAKU.YAKUS["Double Riichi"])
	else:
		met_yaku.hans.append(ALL_YAKU.YAKUS["Riichi"])
	MusicManager.start_tenpai()
	_start_rotation()


# some items call this after making mods
func update_hand_label(override_sort = false):
	if !override_sort:
		hand.sort_custom(Callable(MTile, "tile_compare"))
	gui_manager.update_hand(hand)


# `does_not_count` just prevents certain tile draws from decrementing counters
func _get_next_from_wall(does_not_count = false):
	if wall.size() == 0:
		_end_round()
		return null
	var ret = wall.pop_back()
	gui_manager.update_wall_count(wall.size())
	
	if !does_not_count:
		items.tile_drawn()
	
	ippatsu_counter -= 1
	
	return ret


func _end_round(win_is_tsumo_not_ron = false):
	# dora and uradora ids.
	var omote_doras = []
	var ura_doras = []
	for i in range(upgrades.get_kan_size()-revealed_kan_dora, kan_dora.size()):
		for id in kan_dora[i].get_dora_id():
			omote_doras.append(id)
	if !hand_is_open():
		for i in range(upgrades.get_kan_size()-revealed_kan_dora, kan_dora.size()):
			for id in ura_dora[i].get_dora_id():
				ura_doras.append(id)
	var doras = [omote_doras, ura_doras]
	
	# add yaku 
	if ippatsu_counter >= 0:
		met_yaku.hans.append(ALL_YAKU.YAKUS["Ippatsu"])
	if wall.size() == 0:
		met_yaku.hans.append(ALL_YAKU.YAKUS["Haitei"])
	if was_last_draw_from_dead_wall:
		met_yaku.hans.append(ALL_YAKU.YAKUS["Rinshan"])
	
	var score_info = yaku_checker.hand_get_han(get_hand_info(), doras, true, met_yaku)
	
	var multiplier_info = MultiplierInfo.new(seat_wind == WINDS.EAST, win_is_tsumo_not_ron)
	
	# lock self up until next round
	_set_state(STATE_ANIMATING)
	
	#print("%d  %d  %d" % [fu, han, multiplier])
	root.end_round(score_info, multiplier_info)
	
	MusicManager.start_scoring()
	
	# moved to root temporarily(?)
	#TileGraphicKnower.update_dora_ids([])


func _set_state(new_state: int):
	if _state == new_state:
		return
	
	_state = new_state
	
	hand_gui.do_hover_cursor(_state == STATE_ACTIONABLE)


# changes state, but otherwise just hacks into existing `tile_graphic_clicked` code
func request_tile_select(requestor: Node, remove_from_hand: bool):
	tile_select_requestor_node = requestor
	remove_from_hand_on_selection = remove_from_hand
	_set_state(STATE_SELECT_TILE)
# called when formally complete, so anims can play out etc.
func complete_tile_select():
	tile_select_requestor_node = null
	remove_from_hand_on_selection = null
	#  quick fix for weird ordering issue, gomenne ;3. we can enter call states
	# if we switch out a tsumo to an agarihai, dont want to override that by accident
	# and ordering is gonna be annoying no matter what so this weird check
	# goes here as a least-bad solution
	if _state != STATE_CALLS:
		_set_state(STATE_ACTIONABLE)

# stall the mahjmanager for other tile selects
func stall_for_external_select():
	_set_state(STATE_ANIMATING)

func get_hand_info() -> HandInformation:
	var ret = HandInformation.new()
	
	ret.hand = hand
	ret.tsumo = tsumo
	ret.already_made_groupings = called_hand
	if opp_discard.size() > 0:
		ret.most_recent_discard = opp_discard[-1]
	
	return ret

func hand_is_open():
	for g in called_hand:
		if g.is_open():
			return true
	return false

func get_called_hand_size() -> int:
	var count = 0
	for g in called_hand:
		if g.type == Grouping.PAIR:
			count += 1
		elif g.type == Grouping.SPECIAL:
			pass
		else:
			count += 3
	return count

static func first_by_id(id: int, tiles: Array) -> int:
	for t in tiles.size():
		if tiles[t].get_id() == id:
			return t
	return -1
static func count_by_id(id: int, tiles: Array) -> int:
	var count = 0
	for t in tiles.size():
		if tiles[t].get_id() == id:
			count += 1
	return count

