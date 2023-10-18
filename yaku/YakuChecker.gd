extends Node
class_name YakuChecker
@onready var mahjong_manager = %MahjongManager

var YAKU = {
	"Ready": [1, "To enter ready hand, hand must be closed and 1 tile from completion. Once entered, hand cannot be modified."] 
}


# hand should be sorted by MTile id.
func hand_get_han(hand: Array, already_opened_groupings: Array, is_tsumo: bool, dora = []) -> int:
	var is_open = already_opened_groupings.size() > 0
	
	var han = 0
	
	var remaining_hand = hand.duplicate()
	var groupings = get_maximal_groupings(remaining_hand)
	groupings.append_array(already_opened_groupings)
	
	
	if groupings_meet_basic_reqs(groupings):
		# check half and full flushes
		var suit = hand[0].suit
		if suit != MTile.SUITS.SPECIAL: #different yaku
			var is_full = true
			var is_half = true
			for t in hand:
				if t.suit == suit:
					continue
				if t.suit == MTile.SUITS.SPECIAL:
					is_full = false
					continue
			
			if is_full:
				han += 6 - int(is_open)
			elif is_half:
				han += 3 - int(is_open)
		
		# menzentsumo
		if !is_open and is_tsumo:
			han += 1
		
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
					if [mahjong_manager.seat_wind+1, mahjong_manager.prevalent_wind+1, MTile.SPECIALS.CHUN, MTile.SPECIALS.HAKU, MTile.SPECIALS.HATSU].has(g.tiles[0].suit):
						han += 1
		
		# tanyao
		var tanyao = true
		for g in groupings:
			for t in g.tiles:
				if t.suit == MTile.SUITS.SPECIAL or t.value == 1 or t.value == 9:
					tanyao = false
		if tanyao:
			han += 1
	
	if dora.size() > 0:
		han += get_dora(groupings, dora)
	
	return han

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
func get_maximal_groupings(remaining_hand: Array) -> Array: #return array is of `Grouping`s
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

func get_fu(groupings: Array):
	return 30
