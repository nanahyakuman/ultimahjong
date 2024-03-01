extends Node
class_name YakuChecker
@onready var mahjong_manager = %MahjongManager
@onready var ALL_YAKU = $"../YakuFu"

var character_info: CharacterInfo

func initialize(ci: CharacterInfo, load: bool):
	character_info = ci

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
	
	# kokushi is only ever kokushi, just escape case it as early as possible
	if _is_kokushi(remaining_hand):
		var ret = ScoringInfo.new()
		ret.hans.append(ALL_YAKU.YAKUS["Kokushi Musou"])
		return ret
	
	#  get maximal hands, run based and set based. note this is pretty wasteful most
	# of the time, especially since every extant biruntrpair doubles the amount of groupings
	# to be tested, and the majority of hands aren't even ambiguous
	var groupingss = [_get_maximal_groupings(remaining_hand,false),_get_maximal_groupings(remaining_hand,true)]
	
	#break down biruntripairs into constituents
	var expanded_groupingss = []
	var gssi = 0
	while gssi < groupingss.size():
		var gss = groupingss[gssi]
		for g in gss:
			if g.type == Grouping.BIRUNTRIPAIR:
				var rundupe = gss.duplicate()
				rundupe.erase(g)
				var pairdupe = rundupe.duplicate()
				
				rundupe.append(Grouping.new(Grouping.RUN,[g.tiles[0],g.tiles[2],g.tiles[4]]))
				rundupe.append(Grouping.new(Grouping.RUN,[g.tiles[1],g.tiles[3],g.tiles[5]]))
				
				pairdupe.append(Grouping.new(Grouping.PAIR,[g.tiles[0],g.tiles[1]]))
				pairdupe.append(Grouping.new(Grouping.PAIR,[g.tiles[2],g.tiles[3]]))
				pairdupe.append(Grouping.new(Grouping.PAIR,[g.tiles[4],g.tiles[5]]))
				
				groupingss.erase(gss)
				groupingss.append(rundupe)
				groupingss.append(pairdupe)
				# just reset back to the beginning. this is kinda wasteful ngl
				gssi = -1
				break
		gssi += 1
	
	# determine openness
	var is_open = false
	for g in hand_info.already_made_groupings:
		if g.is_open():
			is_open = true
			break
	
	# for addons that demand basic reqs(e.g. riichi)
	var met_basic_reqs = false
	
	# highest scoring hand
	var max = ScoringInfo.new()
	
	
	for groupings in groupingss:
		groupings.append_array(hand_info.already_made_groupings)
		
		var scoring_info = ScoringInfo.new()
		scoring_info.open = is_open
		
		if _groupings_meet_basic_reqs(groupings):
			met_basic_reqs = true
			
			# generate metadata for faster scanning later on
			var sets = []
			var runs = []
			var pairs = []
			var duplicates = []
			#  need a tracker for this to break sanankou. this will be empty
			# on a tsumo win
			var groupings_that_might_contain_ronned_tile = []
			for g in groupings:
				match g.type:
					Grouping.RUN:
						runs.append(g)
					Grouping.SET:
						sets.append(g)
					Grouping.PAIR:
						pairs.append(g)
					Grouping.BIRUNTRIPAIR:
						assert(false, "You're meant to filter these out!")
				
				#  sanankou breaker. second half of logic occurs in the sanankou section
				# below
				if !is_tsumo:
					for t in g.tiles:
						if t.get_id() == hand_info.most_recent_discard.get_id():
							groupings_that_might_contain_ronned_tile.append(g)
			
			
			#  find dupes. have to use a manual iterator so we can reset it.
			# its not that sightly but we just run thruogh the array over and
			# over until there's no dupes, every time we find one we just delete
			# both from the dupe array and start back over
			var groupings_clone = groupings.duplicate()
			var it = 0
			while it < groupings_clone.size():
				for j in range(it+1, groupings_clone.size()):
					if groupings_clone[it].equivalent(groupings_clone[j]):
						duplicates.append(groupings_clone[it])
						groupings_clone.remove_at(it)
						# ugly ahh offsetter becuase removals are int based
						groupings_clone.remove_at(j - int(it < j))
						it = 0
						break
				it += 1
			
			
			## LUCK-BASED (that `MahjongManager` doesn't already deal with)
			#  this looks wrong at first but menzentsumo is encoded to lose one han
			# if opened, so this adds 1-1=0 han to an open hand.
			if is_tsumo:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Menzentsumo"])
			
			
			## OTHER 1-HAN YAKU (put here for nicer ordering)
			
			# yakuhaki
			for g in groupings:
				var ykvals = get_yakuhai_vals()
				if g.type == Grouping.SET:
					if g.tiles[0].suit == MTile.SUITS.SPECIAL:
						for i in ykvals.count(g.tiles[0].value):
							YakuChecker.append_or_merge_yaku(scoring_info.hans, ALL_YAKU.YAKUS["Yakuhai"])
			
			# tanyao
			#if !is_open:
			var tanyao = true
			for g in groupings:
				if g.type == Grouping.SPECIAL:
					continue
				for t in g.tiles:
					if t.suit == MTile.SUITS.SPECIAL or t.value == 1 or t.value == 9:
						tanyao = false
			if tanyao:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Tan'yao"])
			
			
			## PAIR-BASED YAKU (the only one)
			##  defifnition is funny to permit different hand sizes
			if runs.size() == 0 and sets.size() <= 1:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Chiitoitsu"])
			
			# filter out chiitoi
			else:
				#  sanankou, sankantsu, suuankou, suukantsu. moved
				# here to disable fu from overscoring
				var hidden_sets = []
				var kans = []
				for s in sets:
					if !s.is_open():
						hidden_sets.append(s)
					if s.tiles.size() == 4:
						kans.append(s)
				
				#  have to un-open a set if it's a ron-ned tile completing it. this 
				# has to be more complicated than i'd like to account for dopey supersets
				# like 333/333p as two koutsu.
				var sets_that_might_contain_ronned_tile = []
				for g in groupings_that_might_contain_ronned_tile:
					if hidden_sets.has(g):
						sets_that_might_contain_ronned_tile.append(g)
				# check if there's any other grouping that could contain it instead.
				if sets_that_might_contain_ronned_tile.size() > 0:
					if sets_that_might_contain_ronned_tile.size() == groupings_that_might_contain_ronned_tile.size():
						# doesnt work 
						sets_that_might_contain_ronned_tile[-1].open_tile = 99
						hidden_sets.erase(sets_that_might_contain_ronned_tile[-1])
					
				## SET-BASED YAKU (all req. at least 3 sets)
				if sets.size() >= 3:
					# toitoi
					if runs.size() == 0:
						scoring_info.hans.append(ALL_YAKU.YAKUS["Toitoi"])
					
					if hidden_sets.size() >= 4:
						scoring_info.hans.append(ALL_YAKU.YAKUS["Suuankou"])
					elif hidden_sets.size() == 3:
						scoring_info.hans.append(ALL_YAKU.YAKUS["San'ankou"])
					if kans.size() >= 4:
						scoring_info.hans.append(ALL_YAKU.YAKUS["Suukantsu"])
					elif kans.size() == 3:
						scoring_info.hans.append(ALL_YAKU.YAKUS["Sankantsu"])
					
					#sanshoku doukou
					var possesed_sets = []
					possesed_sets.resize(9)
					possesed_sets.fill(0)
					for s in sets:
						possesed_sets[s.tiles[0].value-1] |= s.tiles[0].suit
					
					for ps in possesed_sets:
						if ps == 7: # i.e. 1 | 2 | 4
							scoring_info.hans.append(ALL_YAKU.YAKUS["Sanshoku Doukou"])
				
				
				## RUN-BASED YAKU (note all require at least 2 runs)
				if runs.size() >= 2:
					# 1/2peikou
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
						var itsuu_suits = {MTile.SUITS.PIN: 0b000, MTile.SUITS.SOU: 0b000, MTile.SUITS.MAN: 0b000, MTile.SUITS.CHO: 0b000}
						for g in runs:
							for index in [0,1,2]:
								if g.tiles[0].value == index*3 + 1:
									itsuu_suits[g.tiles[0].suit] |= int(pow(2,index))
						for s in itsuu_suits.keys():
							if itsuu_suits[s] == 7:
								scoring_info.hans.append(ALL_YAKU.YAKUS["Ittsuu"])
						
						# sanshoku
						# works similar to itsuu, but by val instead of suit
						var sanshoku_vals = {}
						for i in 9:
							sanshoku_vals[i+1] = 0
						for g in runs:
							sanshoku_vals[g.tiles[0].value] |= g.tiles[0].suit
						for v in sanshoku_vals.keys():
							if sanshoku_vals[v] == 7:
								scoring_info.hans.append(ALL_YAKU.YAKUS["Sanshoku Doujun"])
			
			
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
			
			if ![MTile.SUITS.SPECIAL, MTile.SUITS.FLOWER].has(suit): #different yaku
				var is_full = true
				var is_half = true
				for g in groupings:
					# disregard nuki dora
					if g.type == Grouping.SPECIAL:
						continue
					for t in g.tiles:
						if t.suit == suit:
							continue
						if t.suit == MTile.SUITS.SPECIAL:
							is_full = false
							continue
						is_half = false
						is_full = false
				
				if is_full:
					scoring_info.hans.append(ALL_YAKU.YAKUS["Chin'itsu"])
				elif is_half:
					scoring_info.hans.append(ALL_YAKU.YAKUS["Hon'itsu"])
				
				if is_full:
					var chuuren_bitmask = []
					chuuren_bitmask.resize(9)
					chuuren_bitmask.fill(0)
					for g in groupings:
						for t in g.tiles:
							chuuren_bitmask[t.value-1] += 1
					
					var chuuren_valid = true
					if chuuren_bitmask[9-1] < 3:
						chuuren_valid = false
					if chuuren_bitmask[1-1] < 3:
						chuuren_valid = false
					for i in range(2-1, 8-1+1):
						if chuuren_bitmask[i] < 1:
							chuuren_valid = false
							break
					
					if chuuren_valid:
						scoring_info.hans.append(ALL_YAKU.YAKUS["Chuuren Poutou"])
			
			# putting ryuuii here as well
			var ryuuii = true
			for g in groupings:
					for t in g.tiles:
						if t.suit == MTile.SUITS.SPECIAL:
							if t.value != MTile.SPECIALS.HATSU:
								ryuuii = false
								break
						elif t.suit != MTile.SUITS.SOU:
							ryuuii = false
							break
						elif !MTile.RYUUII_VALUES.has(t.value):
							ryuuii = false
							break
					
					if !ryuuii:
						break
			if ryuuii:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Ryuuiisou"])
			
			
			## HONOR/TERMINAL-BASED YAKU
			var terminal_sets = []
			var terminal_runs = []
			var honor_sets = []
			var terminal_pairs = []
			var honor_pairs = []
			var sangen_count = 0
			var gen_pairs = 0
			var wind_count = 0
			var wind_pairs = 0
			var groupings_count_excluding_flowers = 0
			groupings_count_excluding_flowers = groupings.size()
			for g in groupings:
				if g.type == Grouping.SET:
					if MTile.NUMERALS.has(g.tiles[0].suit):
						if g.tiles[0].value == 1 or g.tiles[0].value == 9:
							terminal_sets.append(g)
					else:
						honor_sets.append(g)
						if MTile.DRAGONS.has(g.tiles[0].value):
							sangen_count += 1
						if MTile.WINDS.has(g.tiles[0].value):
							wind_count += 1
				elif g.type == Grouping.RUN:
					# this is implicit
					#if MTile.NUMERALS.has(g.tiles[0].suit):
					if g.tiles[0].value == 1 or g.tiles[0].value == 7:
						terminal_runs.append(g)
				elif g.type == Grouping.PAIR:
					if MTile.NUMERALS.has(g.tiles[0].suit):
						if g.tiles[0].value == 1 or g.tiles[0].value == 9:
							terminal_sets.append(g)
					else:
						honor_pairs.append(g)
						if MTile.DRAGONS.has(g.tiles[0].value):
							gen_pairs += 1
						if MTile.WINDS.has(g.tiles[0].value):
							wind_pairs += 1
				elif g.type == Grouping.SPECIAL:
					groupings_count_excluding_flowers -= 1
			
			# all terminals
			if terminal_pairs.size() + terminal_sets.size() == groupings_count_excluding_flowers:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Chinroutou"])
			# all honors:
			elif honor_pairs.size() + honor_sets.size() == groupings_count_excluding_flowers:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Tsuuiisou"])
			# all terminals/honors
			elif terminal_pairs.size() + terminal_sets.size() + honor_sets.size() + honor_pairs.size() == groupings_count_excluding_flowers:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Honroutou"])
			elif terminal_pairs.size() + terminal_sets.size() + terminal_runs.size() == groupings_count_excluding_flowers:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Junchan"])
			elif terminal_pairs.size() + terminal_sets.size() + honor_sets.size() + honor_pairs.size() + terminal_runs.size() == groupings_count_excluding_flowers:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Chanta"])
			
			# sangen
			if sangen_count >= 3:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Daisangen"])
			elif sangen_count >= 2 and gen_pairs >= 1:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Shousangen"])
			
			# suushi
			if wind_count >= 4:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Daisuushii"])
			elif wind_count >= 3 and wind_pairs >= 1:
				scoring_info.hans.append(ALL_YAKU.YAKUS["Shousuushii"])
			
			# get fu
			if do_fu:
				scoring_info.fus = get_fu(groupings, doras, final_tile)
				
				#tsumo
				if is_tsumo:
					scoring_info.fus.insert(1, ALL_YAKU.FU["Tsumo"].duplicate())
				
				#menzenka
				if !is_open and !is_tsumo:
					scoring_info.fus.insert(1, ALL_YAKU.FU["Menzenkafu"].duplicate())
				
			
				# sneak pinfu in here. we don't check for it unless also checking for fu
				if scoring_info.pinfu_check():
					scoring_info.hans.append(ALL_YAKU.YAKUS["Pinfu"])
				
				
				# chiitoi fu. overrides other fu
				if pairs.size() >= 7:
					scoring_info.fus.clear()
					scoring_info.fus.append(ALL_YAKU.FU["Chiitoitsu"].duplicate())
			
			
			
			if scoring_info.get_base_points() >= max.get_base_points():
				max = scoring_info
	
	# at least meeting basic reqs checker
	if other_met_yaku and met_basic_reqs:
		max.hans = other_met_yaku.hans + max.hans
		
		# only add bonuses to hands with at least one han
		if max.get_total_han() > 0:
			# only counts called flowers, in nukidora fashion
			for g in hand_info.already_made_groupings:
				for t in g.tiles:
					if g.type == Grouping.SPECIAL:
						if t.suit == MTile.SUITS.FLOWER:
							YakuChecker.append_or_merge_yaku(max.hans, ALL_YAKU.YAKUS["Flower"])
						#  these can only be called if you have the upgrade, so no reason
						# to recheck for the upgrade
						if t.suit == MTile.SUITS.SPECIAL and t.value == MTile.SPECIALS.NORTH:
							YakuChecker.append_or_merge_yaku(max.hans, ALL_YAKU.YAKUS["North"])
			
			# dora
			var all_tiles = remaining_hand.duplicate()
			for g in hand_info.already_made_groupings:
				for t in g.tiles:
					all_tiles.append(t)
			if doras.size() > 0:
				for t in all_tiles:
					if t.color == MTile.COL_AKA:
						YakuChecker.append_or_merge_yaku(max.hans, ALL_YAKU.YAKUS["Aka Dora"])
					if t.color == MTile.COL_KIN:
						YakuChecker.append_or_merge_yaku(max.hans, ALL_YAKU.YAKUS["Kin Dora"])
					if doras[0].has(t.get_id()):
						YakuChecker.append_or_merge_yaku(max.hans, ALL_YAKU.YAKUS["Kan Dora"])
					if !is_open and doras[1].has(t.get_id()):
						YakuChecker.append_or_merge_yaku(max.hans, ALL_YAKU.YAKUS["Ura Dora"])
	
	return max

# also called by mahjmanager to stack riichis
static func append_or_merge_yaku(array: Array, yaku: ScoringInfo.Han):
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
	return _groupings_meet_basic_reqs(groupings) or _is_kokushi(hand)

func _groupings_meet_basic_reqs(groupings: Array) -> bool:
	var setruns = 0 # sets or runs
	var pairs = 0 # pairs
	var biruntripairs = 0 # 223344 type shapes that could be either
	var sets = 0
	for gi in groupings.size():
		var g = groupings[gi]
		if g.type == Grouping.SET:
			setruns += 1
			sets += 1
		elif g.type == Grouping.PAIR:
			pairs += 1
		elif g.type == Grouping.RUN:
			setruns += 1
		elif g.type == Grouping.BIRUNTRIPAIR:
			biruntripairs += 1
	
	##  these can probably be figured out programatically
	## but it's honestly easier just to hardcode
	# regular
	if character_info.hand_size == 14:
		return ((setruns + 2 * biruntripairs == 4) and (pairs == 1)) or (pairs + biruntripairs * 3 == 7)
	#'xl'
	elif character_info.hand_size == 17:
		return ((setruns + 2 * biruntripairs == 5) and (pairs == 1)) or ((pairs + biruntripairs * 3 == 7) and sets == 1)
	# 'sichuan'
	elif character_info.hand_size == 8:
		return ((setruns + 2 * biruntripairs == 2) and (pairs == 1)) or (pairs + biruntripairs * 3 == 4)
	# slightly smaller
	elif character_info.hand_size == 11:
		return ((setruns + 2 * biruntripairs == 3) and (pairs == 1)) or ((pairs + biruntripairs * 3 == 4) and sets == 1)
	
	assert(false,"invalid hand size!")
	return false

func _is_kokushi(hand: Array):
	# only allow full hands
	if hand.size() != 14:
		return false
	var found_ids = [] 
	for t in hand:
		if t.suit == MTile.SUITS.SPECIAL:
			var tid = t.get_id()
			# only want 1 pair. this check is technically redundant but saves time
			if found_ids.count(tid) > 1:
				return false
			else:
				if found_ids.find(tid) == -1:
					found_ids.append(tid)
		else:
			if ![1,9].has(t.value):
				return false
			
			var tid = t.get_id()
			# only want 1 pair. this check is technically redundant but saves time
			if found_ids.count(tid) > 1:
				return false
			else:
				if found_ids.find(tid) == -1:
					found_ids.append(tid)
			
	# we need all 13
	if found_ids.size() < 13:
		return false
	#  don't have to check for only one pair because it's implicit
	# with the above check
	return true


#  lil slow ngl. if `remaining_hand` does not fully resolve, returns an empty array.
# e.g. 1234m returns nothing bc the 4 is hanging. this will work for hands of arbitrary sizes,
# in fact, that's how it recurses.
func _get_maximal_groupings(remaining_hand: Array, prioritize_runs_not_sets: bool = false) -> Array: #return array of `Grouping`s
#	var str = ""
#	for i in remaining_hand:
#		str += " " + i.get_name()
#	print(recount, str)
	
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
			elif type_index == 1:
				group = is_of_run(t, remaining_hand)
		else:
			if type_index == 0:
				group = is_of_run(t, remaining_hand)
			elif type_index == 1:
				group = is_of_set(t, remaining_hand)
		# pairs
		if type_index == 2:
			group = is_of_set(t, remaining_hand, 2)
		
		#  recurse if we find a group. otherwise we loop around to the next type
		# of grouping
		if group:
			var theoretically_mananged_tiles = remaining_hand.duplicate()
			for tg in group.tiles:
				theoretically_mananged_tiles.erase(tg)
			
			var recurse = _get_maximal_groupings(theoretically_mananged_tiles, prioritize_runs_not_sets)
			var theoretical_all_groupings = []
			var merged = false
			#  check if we sshould merge up. a biruntripair (basically an iipeikou, i.e. 223344)
			# could either be 3 pairs or 2 runs, but it's easier to remember them both
			# in a meta-structure here.
			if group.type == Grouping.RUN:
				for g in recurse:
					if g.equivalent(group):
						merged = true
						g.type = Grouping.BIRUNTRIPAIR
						g.tiles.append_array(group.tiles)
						g.tiles.sort_custom(Callable(MTile, "tile_compare"))
						break
			if !merged:
				theoretical_all_groupings = [group]
			theoretical_all_groupings.append_array(recurse)
			# only care if we use all tiles
			if size_of_groupings(theoretical_all_groupings) == remaining_hand.size():
				maximal_groupings = recurse.duplicate()
				# dont double-merge dummy!
				if !merged:
					maximal_groupings.append(group)
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
		return Grouping.new(Grouping.RUN, [tile, has_next, has_nexter])
	return null

#  "size" allows this function to detect atama, kotsu, and kan. this will
# trim automatically, so isofset(3m, [33333m], 2) returns an array of the first two 3m.
func is_of_set(tile: MTile, hand:Array, size: int = 3):
	var id = tile.get_id()
	# get tiles
	var tiles_in_set = []
	for t in hand:
		if t.get_id() == id:
			tiles_in_set.append(t)
	
	# trim off excess
	if tiles_in_set.size() > size:
		tiles_in_set.resize(size)
	# not enough
	elif tiles_in_set.size() < size:
		return false
	var type = Grouping.PAIR if size == 2 else Grouping.SET
	return Grouping.new(type, tiles_in_set)


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
			Grouping.BIRUNTRIPAIR:
				count += 6
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
			if g.is_open():
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
			
			if g.is_open():
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
				# will be tr()'d
				fus.back().nam += ("_YAOCHUU")
		
		elif g.type == Grouping.PAIR:
			if g.tiles[0].suit == MTile.SUITS.SPECIAL and get_yakuhai_vals().has(g.tiles[0].value):
				fus.append(ALL_YAKU.FU["Yakuhai Pair"].duplicate())
			else:
				fus.append(ALL_YAKU.FU["Pair"].duplicate())
			
			if g.tiles[0].get_id() == waited_tile.get_id():
				award_wait_fu = true
		
		
	
	if award_wait_fu:
		fus.append(ALL_YAKU.FU["1-sided Wait"].duplicate())
	
	for g in groupings:
		for t in g.tiles:
			if t.color == MTile.COL_AO:
				fus.append(ALL_YAKU.FU["Ao Dora"].duplicate())
	
	
	return fus



func get_yakuhai_vals() -> Array:
	# offset to convert mhjman winds to mtile winds
	return [mahjong_manager.seat_wind+1, mahjong_manager.prevalent_wind+1] + MTile.DRAGONS
