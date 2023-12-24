extends Node

# this MUST remain sorted for the tiles tab to display properly!
var tile_data = []

signal updated

# fairly striaghtforward gen code, just don't forget to assign tiles unique ids!!
func initialize(character_info: CharacterInfo):
	match character_info.type:
		# normal riichi, with a single shiropocchi
		character_info.REGULAR:
			for i in [MTile.SUITS.MAN, MTile.SUITS.PIN, MTile.SUITS.SOU]:
				for j in 9:
					for k in 4:
						var a = MTile.new(i,j+1)
						tile_data.append(a)
					if j+1 == 5:
						tile_data[-4].color = MTile.COL_AKA
#					if j+1 == 3:
#						tile_data[-4].color = MTile.COL_AO
			
			for i in MTile.DEF_SPECIALS:
				for k in 4:
					var a = MTile.new(MTile.SUITS.SPECIAL, i)
					tile_data.append(a)
				if i == MTile.SPECIALS.HAKU:
					tile_data.back().pocchi = true
		
		
		# normal sanma
		character_info.SANMA:
			for k in 4:
				for val in [1,9]:
					var a = (MTile.new(MTile.SUITS.MAN,val))
					tile_data.append(a)
			
			for i in [MTile.SUITS.PIN, MTile.SUITS.SOU]:
				for j in 9:
					for k in 4:
						var a = MTile.new(i,j+1)
						tile_data.append(a)
					if j == 4:
						tile_data[-4].color = MTile.COL_AKA
			
			for i in MTile.DEF_SPECIALS:
				for k in 4:
					var a = MTile.new(MTile.SUITS.SPECIAL, i)
					tile_data.append(a)
		
		
		#no honors
		character_info.NO_HONORS:
			for i in [MTile.SUITS.MAN, MTile.SUITS.PIN, MTile.SUITS.SOU, MTile.SUITS.CHO]:
				for j in 9:
					for k in 4:
						var a = MTile.new(i,j+1)
						tile_data.append(a)
					if j+1 == 5:
						tile_data[-4].color = MTile.COL_AKA
	
	# temp flower code here
#	for i in 4:
#		tile_data.append(MTile.new(MTile.SUITS.FLOWER, i+1))
	
	#  this should ideally do nothing at all, but for safety we call it
	# anyway
	tile_data.sort_custom(Callable(MTile, "tile_compare"))
	
	emit_signal("updated")


func get_all_tiles():
	var ret = []
	for t in tile_data:
		ret.append(t.duplicate_canonize())
	return ret

func get_all_unique_tiles():
	var ret = []
	var ids = []
	for t in tile_data:
		if !ids.has(t.get_id()):
			ret.append(t)
			ids.append(t.get_id())
	return ret

func get_random_non_colored_ids(amount_in_group: int, groups: int):
	var ret = []
	
	var tiles = get_all_tiles()
	tiles.shuffle()
	
	for GI in groups:
		var subret = []
		var counter = 0
		while tiles.size() > 0 and counter < amount_in_group:
			var next = tiles.pop_back()
			if next.color != MTile.COL_NONE:
				continue
			subret.append(next)
			counter += 1
		subret.sort_custom(Callable(MTile, "tile_compare"))
		ret.append(subret)
	
	return ret


const TILE_SAME_SUIT_CHANCE = .4
const TILE_ADJ_VALUE_CHANCE = .3

func get_random_tiles_to_add(amount_in_group: int, groups: int):
	var ret = []
	
	for g in groups:
		var subret = []
		
		var curr = _get_random_tile()
		subret.append(curr)
		for i in range(1, amount_in_group):
			# weight to generate adjacent tiles
			var suit_ovr = -1
			var val_ovr = -1
			#  dont gen adjacents for specials. half becuase itd break
			# (getadj doesnt work on specials) and half because its op.
			if curr.suit != MTile.SUITS.SPECIAL:
				if randf() < TILE_SAME_SUIT_CHANCE:
					suit_ovr = curr.suit
					if randf() < TILE_ADJ_VALUE_CHANCE:
						val_ovr = MTile.tile_from_id(curr.get_adj_ids().pick_random()).value
			
			curr = _get_random_tile(suit_ovr, val_ovr)
			subret.append(curr)
		
		subret.sort_custom(Callable(MTile, "tile_compare"))
		ret.append(subret)
	
	return ret

func _get_random_tile(suit_override: int = -1, val_override: int = -1) -> MTile:
	var suit = suit_override
	var value = val_override
	if suit == -1:
		suit = [MTile.SUITS.PIN, MTile.SUITS.SOU, MTile.SUITS.MAN, MTile.SUITS.SPECIAL].pick_random()
	
	if value == -1:
		value = (randi() % 9) + 1
		if suit == MTile.SUITS.SPECIAL:
			value = MTile.DEF_SPECIALS.pick_random()
	return MTile.new(suit, value)


func increment_tile(tile: MTile):
	# add the new tile to the list, and give it a unique id
	var new_tile = tile.duplicate()
	tile_data.append(new_tile)
	tile_data.sort_custom(Callable(MTile, "tile_compare"))
	
	emit_signal("updated")

func set_color(tile: MTile, color: int):
	
	tile.canon_tile.color = color
	
	emit_signal("updated")
