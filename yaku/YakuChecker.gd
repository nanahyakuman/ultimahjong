extends Node
class_name YakuChecker
@onready var mahjong_manager = %MahjongManager
@onready var ALL_YAKU = $"../YakuFu"


# hand should be sorted by MTile id. this is slow
func hand_get_han(hand: Array, already_opened_groupings: Array, is_tsumo: bool, doras = [], do_fu = false, other_met_yaku: ScoringInfo = null) -> ScoringInfo:
	var is_open = already_opened_groupings.size() > 0
	
	
	var remaining_hand = hand.duplicate()
	var groupingss = [_get_maximal_groupings(remaining_hand,false),_get_maximal_groupings(remaining_hand,true)]
	
	var max = null
	
	for groupings in groupingss:
		groupings.append_array(already_opened_groupings)
		
		var scoring_info = ScoringInfo.new()
		
		if groupings_meet_basic_reqs(groupings):
	#		for g in groupings:
	#			g.print_self()
	#		print()
			
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
				var ykvals = get_yakuhai_vals()
				if g.type == Grouping.SET:
					if g.tiles[0].suit == MTile.SUITS.SPECIAL:
						if ykvals.has(g.tiles[0].value):
							scoring_info.hans.append(ALL_YAKU.YAKUS["Yakuhai"])
			
			# tanyao
			if !is_open:
				var tanyao = true
				for g in groupings:
					for t in g.tiles:
						if t.suit == MTile.SUITS.SPECIAL or t.value == 1 or t.value == 9:
							tanyao = false
				if tanyao:
					scoring_info.hans.append(ALL_YAKU.YAKUS["Tan'yao"])
			
			# toitoi
			var sets = 0
			for g in groupings:
				if g.type == Grouping.SET:
					sets += 1
			if sets >= 4:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Toitoi"])
			
			# iipeikou
			if !is_open:
				for i in groupings.size():
					for j in range(i+1, groupings.size()):
						var g = groupings[i]
						var g2 = groupings[j]
						
						if g.type == Grouping.RUN and g2.type == Grouping.RUN:
							if g.tiles[0].get_id() == g2.tiles[0].get_id():
								scoring_info.hans.append(ALL_YAKU.YAKUS["Iipeikou"])
		
		if do_fu:
			scoring_info.fus = get_fu(groupings, doras)
		
		if !max:
			max = scoring_info
		else:
			if scoring_info.get_total_points() > max.get_total_points():
				max = scoring_info
	
	if other_met_yaku and max.hans.size() > 0:
		max.hans.append_array(other_met_yaku.hans)
	
	return max

# does not check chitoitsu
func hand_meets_basic_reqs(hand: Array) -> bool:
	var groupings = _get_maximal_groupings(hand)
	return groupings_meet_basic_reqs(groupings)

func groupings_meet_basic_reqs(groupings: Array) -> bool:
	var setruns = 0
	var pairs = 0
	for g in groupings:
		if g.type == Grouping.SET or g.type == Grouping.RUN:
			setruns += 1
		if g.type == Grouping.PAIR:
			pairs += 1
	
	return (setruns >= 4) and (pairs >= 1) 



#  lil slow ngl. if `remaining_hand` does not fully resolve, returns an empty array.
# e.g. 1234m returns nothing bc the 4 is hanging. this will work for hands of arbitrary sizes,
# if that's helpful.
func _get_maximal_groupings(remaining_hand: Array, prioritize_runs_not_sets: bool = false, prefix = "") -> Array: #return array of `Grouping`s
#	var a = []
#	for t in remaining_hand:
#		a.append(t.get_name())
#	print(remaining_hand.size(), ": ", prefix, a)
	
	var maximal_groupings = []
	
	#  if it's 0, this is a positive escape case because counts will align.
	# if it's 1, this is a negative because counts will not.
	if remaining_hand.size() < 2:
		return []
	
	var t = remaining_hand[0]
	
	for type_index in 3:
		var group = null
		var type = null
		#  ugly but should solve issues where we need to check for both runs and sets.
		# prioritize runs otherwise
		if !prioritize_runs_not_sets:
			if type_index == 0:
				group = is_of_set(t, remaining_hand)
				type = Grouping.SET
			elif type_index == 1:
				group = is_of_run(t, remaining_hand)
				type = Grouping.RUN
		else:
			if type_index == 0:
				group = is_of_run(t, remaining_hand)
				type = Grouping.RUN
			elif type_index == 1:
				group = is_of_set(t, remaining_hand)
				type = Grouping.SET
		# pairs
		if type_index == 2:
			group = is_of_set(t, remaining_hand, 2)
			type = Grouping.PAIR
		
		# recurse if we find a group
		if group:
			var theoretically_mananged_tiles = remaining_hand.duplicate()
			for tg in group:
				theoretically_mananged_tiles.erase(tg)
			
			var recurse = _get_maximal_groupings(theoretically_mananged_tiles, prioritize_runs_not_sets, prefix + "  ")
			var new_group = Grouping.new(type,group)
			var theoretical_all = [new_group]
			theoretical_all.append_array(recurse)
			# only care if we use all tiles
			if size_of_groupings(theoretical_all) == remaining_hand.size():
				maximal_groupings = recurse.duplicate()
				maximal_groupings.append(new_group)
				return maximal_groupings
	
	return []

# actually only scans rightwards, so [234m] in sequence returns a set for 2m, but not 3m or 4m
func is_of_run(tile: MTile, hand:Array):
	# no runs of specials atm
	if tile.suit == MTile.SUITS.SPECIAL:
		return
	
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

#  "size" allows this function to detect atama and kan. note this checks PRECISE
# size, so 333m is NOT atama!
func is_of_set(tile: MTile, hand:Array, size: int = 3):
	var id = tile.get_id()
	
	var count = 0
	var tiles_in_set = []
	for t in hand:
		if t.get_id() == id:
			count += 1
			tiles_in_set.append(t)
	
	#  do not `.resize()` `tiles_in_set` to `size`!!!! i know you want to but it
	# breaks things!!!!
	return tiles_in_set if count >= size else null

# get the amount of tiles in an array of groupings
func size_of_groupings(gs: Array) -> int:
	var count = 0
	for g in gs:
		match g.type:
			Grouping.PAIR:
				count += 2
			Grouping.SET:
				count += 3
			Grouping.RUN:
				count += 3
	return count

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
			if g.open:
				fus.append(ALL_YAKU.FU["Open Run"].duplicate())
			else:
				fus.append(ALL_YAKU.FU["Closed Run"].duplicate())
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
		
		# apply yao mult
		var is_yao = true
		for t in g.tiles:
			if t.suit != MTile.SUITS.SPECIAL:
				is_yao = false
				break
		
		if is_yao:
			fus.back().fu *= ALL_YAKU.FU["Yaochuu Multiplier"].fu
			fus.back().nam = "Yaochuu " + fus.back().nam
	
	
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
