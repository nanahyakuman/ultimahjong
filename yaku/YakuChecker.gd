extends Node
class_name YakuChecker
@onready var mahjong_manager = %MahjongManager
@onready var ALL_YAKU = $"../YakuFu"


# hand should be sorted by MTile id.
func hand_get_han(hand: Array, already_opened_groupings: Array, is_tsumo: bool, doras = [], do_fu = false) -> ScoringInfo:
	var is_open = already_opened_groupings.size() > 0
	
	var scoring_info = ScoringInfo.new()
	
	var remaining_hand = hand.duplicate()
	var groupings = get_maximal_groupings(remaining_hand)
	groupings.append_array(already_opened_groupings)
	
#	for g in groupings:
#		for t in g.tiles:
#			print(t.get_id(), " ")
#		print("\n")
	
	if groupings_meet_basic_reqs(groupings):
		# check half and full flushes.
		var suit = 0
		var suit_it = 0
		# weird iterator finds the first suit if we have one
		while groupings[suit_it].tiles[0].suit == MTile.SUITS.SPECIAL:
			suit_it += 1
			if suit_it >= groupings.size()-1:
				suit = MTile.SUITS.SPECIAL
				break
		
		suit = groupings[suit_it].tiles[0].suit
		
		if suit != MTile.SUITS.SPECIAL: #different yaku
			var is_full = true
			var is_half = true
			for g in groupings:
				for t in g.tiles:
					if t.suit == suit:
						continue
					if t.suit == MTile.SUITS.SPECIAL:
						is_full = false
						continue
					is_half = false
					is_full = false
			
			if is_full:
				scoring_info.hans.append(ALL_YAKU.YAKUS[("" if not is_open else "Open ") + "Chin'itsu"])
			elif is_half:
				scoring_info.hans.append(ALL_YAKU.YAKUS[("" if not is_open else "Open ") + "Hon'itsu"])
		
		# menzentsumo
		if !is_open and is_tsumo:
			scoring_info.hans.append(ALL_YAKU.YAKUS["Menzentsumo"])
		
		# pinfu. doesnt account for ryanmen wait rn.
#		if !is_open:
#			var pinfu = true
#			for g in groupings:
#				if g.type == SET:
#					pinfu = false
#				if g.type == PAIR and g.tiles[0].SUIT == MTile.SUITS.SPECIAL:
#					pinfu = false
#			if pinfu:
#				han += 1
		
		# yakuhaki
		for g in groupings:
			if g.type == Grouping.SET:
				if g.tiles[0].suit == MTile.SUITS.SPECIAL:
					if get_yakuhai_vals().has(g.tiles[0].value):
						scoring_info.hans.append(ALL_YAKU.YAKUS["Yakuhai"])
		
		# tanyao
		var tanyao = true
		for g in groupings:
			for t in g.tiles:
				if t.suit == MTile.SUITS.SPECIAL or t.value == 1 or t.value == 9:
					tanyao = false
		if tanyao:
			scoring_info.hans.append(ALL_YAKU.YAKUS["Tan'yao"])
	
	
	if do_fu:
		scoring_info.fus = get_fu(groupings, doras)
	
	return scoring_info

func groupings_meet_basic_reqs(groupings: Array) -> bool:
	var setruns = 0
	var pairs = 0
	for g in groupings:
		if g.type == Grouping.SET or g.type == Grouping.RUN:
			setruns += 1
		if g.type == Grouping.PAIR:
			pairs += 1
	
	return (setruns >= 4) and (pairs >= 1) 

#  this is at least 3x slower than it could theoretically be but it should
# cover all possible arrangements. a better implementation would pregenerate
# all sets and pairs and check for their maximal set instead of starting
# over for every tile
func get_maximal_groupings(remaining_hand: Array) -> Array: #return array of `Grouping`s
	var maximal_groupings = []
	
	if remaining_hand.size() == 2:
		if remaining_hand[0].get_id() == remaining_hand[1].get_id():
			return [Grouping.new(Grouping.PAIR, remaining_hand)]
	
	for t in remaining_hand:
		for type_index in 2:
			var group
			if type_index == 0:
				group = is_of_run(t, remaining_hand)
			else:
				group = is_of_set(t, remaining_hand)
			if group:
				var theoretically_mananged_tiles = remaining_hand.duplicate()
				for tg in group:
					theoretically_mananged_tiles.erase(tg)
				
				var recurse = get_maximal_groupings(theoretically_mananged_tiles)
				if recurse.size() + 1 >= maximal_groupings.size():
					maximal_groupings = recurse.duplicate()
					var type = Grouping.RUN if type_index == 0 else Grouping.SET
					maximal_groupings.append(Grouping.new(type, group))
	
	return maximal_groupings

func is_of_run(tile: MTile, hand:Array):
	#var id = tile.get_id()
	var next_id = MTile.gen_id(tile.suit, tile.value+1)
	var nexter_id = MTile.gen_id(tile.suit, tile.value+2)
	
	var has_next = null
	var has_nexter = null
	
	for t in hand:
		var cid = t.get_id()
		if !has_next and cid == next_id:
			has_next = t
			continue
		if !has_nexter and cid == nexter_id:
			has_nexter = t
			if has_next:
				break
			continue
	
	
	if has_next and has_nexter:
		return [tile, has_next, has_nexter]
	return null

# "size" allows this function to detect atama and kan
func is_of_set(tile: MTile, hand:Array, size: int = 3):
	var id = tile.get_id()
	
	var count = 0
	var tiles_in_set = []
	for t in hand:
		if t.get_id() == id:
			count += 1
			tiles_in_set.append(t)
	
	return tiles_in_set if count == size else null



func get_dora(groupings: Array, dora_ids: Array):
	var dora = 0
	for g in groupings:
		for t in g.tiles:
			if t.aka:
				dora += 1
			dora += dora_ids.count(t.get_id())
	
	return dora

# assumes the hand is valid and not chiitoitsu
func get_fu(groupings: Array, doras: Array):
	var fus = []
	
	fus.append(ALL_YAKU.FU["Base"])
	
	for g in groupings:
		if g.type == Grouping.RUN:
			fus.append(ALL_YAKU.FU["Run"].duplicate())
		elif g.type == Grouping.SET:
			# stitch name together.
			var nam = ""
#			if g.tiles[0].suit == MTile.SUITS.SPECIAL:
#				if get_yakuhai_vals().has(g.tiles[0].value):
#					nam = "Yakuhai "
			
			if g.open:
				nam = nam + "Open "
			else:
				nam = nam + "Closed "
			
			if g.tiles.size() == 3:
				nam = nam + "Set"
			else:
				nam = nam + "Quad"
			
			fus.append(ALL_YAKU.FU[nam].duplicate())
		
		elif g.type == Grouping.PAIR:
#			if g.tiles[0].suit == MTile.SUITS.SPECIAL and get_yakuhai_vals().has(g.tiles[0].value):
#				fus.append(ALL_YAKU.FU["Yakuhai Pair"])
#			else:
			fus.append(ALL_YAKU.FU["Pair"].duplicate())
		
		# apply yakuhai mult
		var is_yakuhai = true
		for t in g.tiles:
			if t.suit == MTile.SUITS.SPECIAL:
				if !get_yakuhai_vals().has(t.value):
					is_yakuhai = false
					break
			else:
				is_yakuhai = false
				break
		
		if is_yakuhai:
			fus.back().fu *= ALL_YAKU.FU["Yakuhai Multiplier"].fu
			fus.back().nam = "Yakuhai " + fus.back().nam
	
	
	# doras is and array of arrays of MTile ids, seperated into front and ura
	if doras.size() > 0:
		for g in groupings:
			for t in g.tiles:
				if doras[0].has(t.get_id()):
					fus.append(ALL_YAKU.FU["Kan Dora"])
				if doras[1].has(t.get_id()):
					fus.append(ALL_YAKU.FU["Ura Dora"])
				if t.aka:
					fus.append(ALL_YAKU.FU["Aka Dora"])
	
	
	return fus



func get_yakuhai_vals() -> Array:
	# offset to convert mhjman winds to mtile winds
	return [mahjong_manager.seat_wind+1, mahjong_manager.prevalent_wind+1, MTile.SPECIALS.CHUN, MTile.SPECIALS.HAKU, MTile.SPECIALS.HATSU]
