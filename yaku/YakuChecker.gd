extends Node
class_name YakuChecker
@onready var mahjong_manager = %MahjongManager
@onready var ALL_YAKU = $"../YakuFu"


# hand should be sorted by MTile id. this is slow
func hand_get_han(hand_info: HandInformation, doras = [], do_fu = false, other_met_yaku: ScoringInfo = null) -> ScoringInfo:
	# merge
	var remaining_hand = hand_info.hand.duplicate()
	
	var final_tile = null
	# determine if tsumo
	var is_tsumo = false
	if hand_info.tsumo:
		final_tile = hand_info.tsumo
		is_tsumo = true
	else:
		final_tile = hand_info.most_recent_discard
	remaining_hand.append(final_tile)
	
	remaining_hand.sort_custom(Callable(MTile, "tile_compare"))
	
	# get maximal hands, run based and set based
	var groupingss = [_get_maximal_groupings(remaining_hand,false),_get_maximal_groupings(remaining_hand,true)]
	
	# determine openness
	var is_open = false
	for g in hand_info.already_made_groupings:
		if g.open:
			is_open = true
			break
	
	# for addons that demand basic reqs(e.g. riichi)
	var met_basic_reqs = false
	
	# highest scoring hand
	var max = ScoringInfo.new()
	
	for groupings in groupingss:
		groupings.append_array(hand_info.already_made_groupings)
		
		var scoring_info = ScoringInfo.new()
		
		if groupings_meet_basic_reqs(groupings):
			met_basic_reqs = true
			
			# generate metadata for faster scanning later on
			var sets = []
			var runs = []
			var pairs = []
			var duplicates = []
			for g in groupings:
				match g.type:
					Grouping.RUN:
						runs.append(g)
					Grouping.SET:
						sets.append(g)
					Grouping.PAIR:
						pairs.append(g)
			
			# have to use a manual iterator so we can advance it
			var it = 0
			while it < groupings.size():
				for j in range(it+1, groupings.size()):
					#  pass on if a dupe is found.
					# this way 111122223333p returns two duplicates ([123.a]>123.b) and ([123.c]>123.d),
					# (bracketed group is the actual one in `duplicates`)
					if groupings[it].equivalent(groupings[j]):
						duplicates.append(groupings[it])
						it = j
						break
				it += 1
			
			
			## LUCK-BASED (that `MahjongManager` doesn't already deal with)
			if !is_open and is_tsumo:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Menzentsumo"])
			
			
			## OTHER 1-HAN YAKU (put here for nicer ordering)
			
			# yakuhaki
			for g in groupings:
				var ykvals = get_yakuhai_vals()
				if g.type == Grouping.SET:
					if g.tiles[0].suit == MTile.SUITS.SPECIAL:
						for i in ykvals.count(g.tiles[0].value):
							append_or_merge_yaku(scoring_info.hans, ALL_YAKU.YAKUS["Yakuhai"])
			
			# tanyao
			if !is_open:
				var tanyao = true
				for g in groupings:
					for t in g.tiles:
						if t.suit == MTile.SUITS.SPECIAL or t.value == 1 or t.value == 9:
							tanyao = false
				if tanyao:
					scoring_info.hans.append(ALL_YAKU.YAKUS["Tan'yao"])
			
			
			## PAIR-BASED YAKU (the only one)
			if pairs.size() >= 7:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Chiitoitsu"])
			
			
			## SET-BASED YAKU (all req. at least 3 sets)
			if sets.size() >= 3:
				# toitoi
				if sets.size() >= 4:
					scoring_info.hans.append(ALL_YAKU.YAKUS["Toitoi"])
				
				# sanankou, sankantsu
				var hidden_count = 0
				var kan_count = 0
				for s in sets:
					if !s.open:
						hidden_count += 1
					if s.tiles.size() == 4:
						kan_count += 1
				
				if hidden_count >= 3:
					scoring_info.hans.append(ALL_YAKU.YAKUS["San'ankou"])
				if kan_count >= 3:
					scoring_info.hans.append(ALL_YAKU.YAKUS["Sankantsu"])
				
				#sanshoku doukou
				var possesed_sets = []
				possesed_sets.resize(9)
				possesed_sets.fill(0)
				for s in sets:
					possesed_sets[s.tiles[0].value-1] |= s.tiles[0].suit
				
				for ps in possesed_sets:
					if ps == 7:
						scoring_info.hans.append(ALL_YAKU.YAKUS["Sanshoku Doukou"])
			
			
			## RUN-BASED YAKU (note all require at least 2 runs)
			if runs.size() >= 2:
				# 1/2peikou
				if !is_open:
					var run_dupe_count = 0
					for d in duplicates:
						if duplicates[0].type == Grouping.RUN:
							run_dupe_count += 1
					if run_dupe_count == 1:
						scoring_info.hans.append(ALL_YAKU.YAKUS["Iipeikou"])
					if run_dupe_count > 1:
						scoring_info.hans.append(ALL_YAKU.YAKUS["Ryanpeikou"])
				
				if runs.size() >= 3:
					# ittsuu
					# weird optimization but basically generates a bitmask for each run in each suit
					var itsuu_suits = {MTile.SUITS.PIN: 0b000, MTile.SUITS.SOU: 0b000, MTile.SUITS.MAN: 0b000}
					for g in runs:
						for index in [0,1,2]:
							if g.tiles[0].value == index*3 + 1:
								itsuu_suits[g.tiles[0].suit] |= int(pow(2,index))
					for s in itsuu_suits.keys():
						if itsuu_suits[s] == 7:
							scoring_info.hans.append(ALL_YAKU.YAKUS["Open Ittsuu" if is_open else "Ittsuu"])
					
					# sanshoku
					# works similar to itsuu, but by val instead of suit
					var sanshoku_vals = {}
					for i in 9:
						sanshoku_vals[i+1] = 0
					for g in runs:
						sanshoku_vals[g.tiles[0].value] |= g.tiles[0].suit
					for v in sanshoku_vals.keys():
						if sanshoku_vals[v] == 7:
							scoring_info.hans.append(ALL_YAKU.YAKUS["Open Sanshoku" if is_open else "Sanshoku Doujun"])
			
			
			## SUIT-BASED YAKU
			
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
			
			
			## TERMINAL-BASED YAKU
			var terminal_sets = []
			var terminal_runs = []
			var honor_sets = []
			var terminal_pairs = []
			var honor_pairs = []
			var sangen_count = 0
			var gen_pairs = 0
			for g in groupings:
				if g.type == Grouping.SET:
					if MTile.NUMERALS.has(g.tiles[0].suit):
						if g.tiles[0].value == 1 or g.tiles[0].value == 9:
							terminal_sets += g
					else:
						honor_sets += g
						if MTile.DRAGONS.has(g.tiles[0].value):
							sangen_count += 1
				elif g.type == Grouping.RUN:
					# this is implicit
					#if MTile.NUMERALS.has(g.tiles[0].suit):
					if g.tiles[0].value == 1 or g.tiles[0].value == 7:
						terminal_runs += g
				elif g.type == Grouping.PAIR:
					if MTile.NUMERALS.has(g.tiles[0].suit):
						if g.tiles[0].value == 1 or g.tiles[0].value == 9:
							terminal_pairs += g
					else:
						honor_pairs += g
						if MTile.DRAGONS.has(g.tiles[0].value):
							gen_pairs += 1
			
			# all terminals
			if terminal_pairs.size() + terminal_sets.size() == groupings.size():
				scoring_info.hans.append(ALL_YAKU.YAKUS["Chinroutou"])
			# all honors:
			if honor_pairs.size() + honor_sets.size() == groupings.size():
				scoring_info.hans.append(ALL_YAKU.YAKUS["Tsuuiisou"])
			# all terminals/honors
			elif terminal_pairs.size() + terminal_sets.size() + honor_sets.size() + honor_pairs.size():
				scoring_info.hans.append(ALL_YAKU.YAKUS["Honroutou"])
			elif terminal_pairs.size() + terminal_sets.size() + terminal_runs.size():
				scoring_info.hans.append(ALL_YAKU.YAKUS[("" if not is_open else "Open ") + "Junchan"])
			elif terminal_pairs.size() + terminal_sets.size() + honor_sets.size() + honor_pairs.size() + terminal_runs.size():
				scoring_info.hans.append(ALL_YAKU.YAKUS[("" if not is_open else "Open ") + "Chanta"])
			
			# sangen
			if sangen_count >= 3:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Daisangen"])
			elif sangen_count >= 2 and gen_pairs >= 1:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Shousangen"])
			
			# get fu
			if do_fu:
				# chiitoi fu
				if pairs.size() >= 7:
					scoring_info.fus.append(ALL_YAKU.FU["Chiitoitsu"].duplicate())
				else:
					scoring_info.fus = get_fu(groupings, doras, final_tile)
					
					#tsumo
					if is_tsumo:
						scoring_info.fus.insert(1, ALL_YAKU.FU["Tsumo"].duplicate())
					
					#mezenka
					if !is_open and !is_tsumo:
						scoring_info.fus.insert(1, ALL_YAKU.FU["Menzenkafu"].duplicate())
				
			
			# sneak pinfu in here
			if !is_open and scoring_info.pinfu_check():
				scoring_info.hans.append(ALL_YAKU.YAKUS["Pinfu"])
			
			
			
			if scoring_info.get_base_points() >= max.get_base_points():
				max = scoring_info
	
	if other_met_yaku and met_basic_reqs:
		max.hans = other_met_yaku.hans + max.hans
		
		# dora
		var all_tiles = remaining_hand.duplicate()
		for g in hand_info.already_made_groupings:
			for t in g.tiles:
				all_tiles.append(t)
		if doras.size() > 0:
			for t in all_tiles:
				if t.aka:
					append_or_merge_yaku(max.hans, ALL_YAKU.YAKUS["Aka Dora"])
				if doras[0].has(t.get_id()):
					append_or_merge_yaku(max.hans, ALL_YAKU.YAKUS["Kan Dora"])
				if !is_open and doras[1].has(t.get_id()):
					append_or_merge_yaku(max.hans, ALL_YAKU.YAKUS["Ura Dora"])
				
	
	return max

func append_or_merge_yaku(array: Array, yaku: ScoringInfo.Han):
	var nam = yaku.nam
	for h in array:
		if h.nam == nam:
			h.count += 1
			return
	# implicit else
	array.append(yaku.duplicate())

# `made_groupings` should only ever contain closed groups (i.e. kans)
func hand_meets_basic_reqs(hand: Array, made_groupings: Array) -> bool:
	var groupings = _get_maximal_groupings(hand)
	groupings.append_array(made_groupings)
	return groupings_meet_basic_reqs(groupings)

func groupings_meet_basic_reqs(groupings: Array) -> bool:
	var setruns = 0
	var pairs = 0
	for g in groupings:
		if g.type == Grouping.SET or g.type == Grouping.RUN:
			setruns += 1
		if g.type == Grouping.PAIR:
			pairs += 1
	
	return ((setruns == 4) and (pairs == 1)) or (pairs == 7)



#  lil slow ngl. if `remaining_hand` does not fully resolve, returns an empty array.
# e.g. 1234m returns nothing bc the 4 is hanging. this will work for hands of arbitrary sizes,
# if that's helpful.
func _get_maximal_groupings(remaining_hand: Array, prioritize_runs_not_sets: bool = false) -> Array: #return array of `Grouping`s
#	var a = []
#	for t in remaining_hand:
#		a.append(t.get_name())
#	print(remaining_hand.size(), ": ", prefix, a)
# note you need to reintroduce the "prefix" argument and increment it every iteration
# to use this
	
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
			
			var recurse = _get_maximal_groupings(theoretically_mananged_tiles, prioritize_runs_not_sets)
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
func get_fu(groupings: Array, doras: Array, waited_tile: MTile):
	var fus = []
	
	fus.append(ALL_YAKU.FU["Base"])
	
	var award_wait_fu = false
	
	for g in groupings:
		if g.type == Grouping.RUN:
			if g.open:
				fus.append(ALL_YAKU.FU["Open Run"].duplicate())
			else:
				fus.append(ALL_YAKU.FU["Closed Run"].duplicate())
				
				# wait fu
				for t in g.tiles:
					if t.get_id() == waited_tile.get_id():
						if (t.value == 3 and g.tiles[0].value == 1) or (t.value == 7 and g.tiles[0].value == 7) or g.tiles.find(t) == 1:
							award_wait_fu = true
				
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
			
			# apply yao mult
			var is_yao = false
			if g.tiles[0].suit == MTile.SUITS.SPECIAL:
				is_yao = true
			elif [1,9].has(g.tiles[0].value):
				is_yao = true
			
			if is_yao:
				fus.back().fu *= ALL_YAKU.FU["Yaochuu Multiplier"].fu
				fus.back().nam = "Yaochuu " + fus.back().nam
		
		elif g.type == Grouping.PAIR:
			if g.tiles[0].suit == MTile.SUITS.SPECIAL and get_yakuhai_vals().has(g.tiles[0].value):
				fus.append(ALL_YAKU.FU["Yakuhai Pair"].duplicate())
			else:
				fus.append(ALL_YAKU.FU["Pair"].duplicate())
			
			if g.tiles[0].get_id() == waited_tile.get_id():
				award_wait_fu = true
		
		
	
	if award_wait_fu:
		fus.append(ALL_YAKU.FU["1-sided Wait"].duplicate())
	
	#  doras is and array of arrays of MTile ids, seperated into front and ura.
	# moved back to be han-scoring
#	if doras.size() > 0:
#		for g in groupings:
#			for t in g.tiles:
#				if doras[0].has(t.get_id()):
#					fus.append(ALL_YAKU.FU["Kan Dora"])
#				if doras[1].has(t.get_id()):
#					fus.append(ALL_YAKU.FU["Ura Dora"])
#				if t.aka:
#					fus.append(ALL_YAKU.FU["Aka Dora"])
	
	
	return fus



func get_yakuhai_vals() -> Array:
	# offset to convert mhjman winds to mtile winds
	return [mahjong_manager.seat_wind+1, mahjong_manager.prevalent_wind+1, MTile.SPECIALS.CHUN, MTile.SPECIALS.HAKU, MTile.SPECIALS.HATSU]
