extends Node
class_name YakuChecker

var YAKU = {
	"Ready": [1, "To enter ready hand, hand must be closed and 1 tile from completion. Once entered, hand cannot be modified."] 
}

func _ready():
#	var singlets = [MTile.new(1, 1), MTile.new(1, 3), MTile.new(1, 5), MTile.new(1, 7)]
#	var hand = []
#	hand.append_array(singlets)
#	hand.append_array(singlets)
#	hand.append_array(singlets)
#	hand.append(MTile.new(1, 9))
#	hand.append(MTile.new(1, 9))
#
#	var open_hand = [ Grouping.new(Grouping.SET, [MTile.new(1, 7), MTile.new(1, 7), MTile.new(1, 7)]) ]
#
#	print(hand_get_han(hand, open_hand, false))
	pass


# hand should be sorted by MTile id.
func hand_get_han(hand: Array, already_opened_groupings: Array, is_tsumo: bool) -> int:
	var is_open = already_opened_groupings.size() > 0
	
	var han = 0
	
	# remove parts of hand that are already open
	var remaining_hand = hand.duplicate()
	var open_groupings_copy = already_opened_groupings.duplicate()
	
	for grouping in already_opened_groupings:
		for g_tile in grouping.tiles:
			for h_tile in remaining_hand:
				if g_tile.get_id() == h_tile.get_id():
					remaining_hand.erase(h_tile)
					break
	
	#  get the maximal groups left in the hand and rejoin the
	# open part of the hand
	var groupings = get_maximal_groupings(remaining_hand)
	groupings.append_array(already_opened_groupings)
	
#	for g in groupings:
#		print(g.type)
#		for t in g.tiles:
#			print(t.get_id())
#	print()
	
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
