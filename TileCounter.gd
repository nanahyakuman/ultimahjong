extends Node

# this MUST remain sorted for the tiles tab to display properly!
@export var tile_data = []

signal updated

var tile_counts: ExpandingCounterDict

# fairly striaghtforward gen code
func initialize(character_info: CharacterInfo, load: bool):
	tile_counts = ExpandingCounterDict.new()
	
	# code is handled in `load_cfg()`
	if load:
		return
	match character_info.type:
		# normal riichi, with a single shiropocchi
		CharacterInfo.TYPES.REGULAR:
			for i in [MTile.SUITS.PIN, MTile.SUITS.SOU, MTile.SUITS.MAN]:
				for j in 9:
					for k in 4:
						var a = MTile.new(i,j+1)
						tile_data.append(a)
					if j+1 == 5:
						tile_data[-4].color = MTile.COL_AKA
			
			# temp d6 tester
			#for i in 6:
			#	var d6 = MTile.new(MTile.SUITS.PIN, 1+i)
			#	d6.unique_type = MTile.UNIQUE.D6
			#	tile_data.append(d6)
			
			for i in MTile.DEF_SPECIALS:
				for k in 4:
					var a = MTile.new(MTile.SUITS.SPECIAL, i)
					tile_data.append(a)
				# pocchi removed for the demo
				#if i == MTile.SPECIALS.HAKU:
				#	tile_data.back().pocchi = true
		
		
		# normal sanma with kin 1
		CharacterInfo.TYPES.SANMA:
			for k in 4:
				for val in [1,9]:
					var a = (MTile.new(MTile.SUITS.MAN,val))
					tile_data.append(a)
			
			for i in [MTile.SUITS.PIN, MTile.SUITS.SOU]:
				for j in 9:
					for k in 4:
						var a = MTile.new(i,j+1)
						tile_data.append(a)
			# gold iisou
			tile_data[-9*4].color = MTile.COL_KIN
			
			for i in MTile.DEF_SPECIALS:
				for k in 4:
					var a = MTile.new(MTile.SUITS.SPECIAL, i)
					tile_data.append(a)
		
		
		#no honors
		CharacterInfo.TYPES.NO_HONORS:
			for i in [MTile.SUITS.MAN, MTile.SUITS.PIN, MTile.SUITS.SOU, MTile.SUITS.CHO]:
				for j in 9:
					for k in 4:
						var a = MTile.new(i,j+1)
						tile_data.append(a)
					if j+1 == 5:
						tile_data[-4].color = MTile.COL_AKA
		
		
		#XL- 17 sized hand, no dora but 8 flowers
		CharacterInfo.TYPES.XL:
			for i in [MTile.SUITS.MAN, MTile.SUITS.PIN, MTile.SUITS.SOU]:
				for j in 9:
					for k in 4:
						var a = MTile.new(i,j+1)
						tile_data.append(a)
			
			for i in MTile.DEF_SPECIALS:
				for k in 4:
					var a = MTile.new(MTile.SUITS.SPECIAL, i)
					tile_data.append(a)
			
#			for i in 8:
#				tile_data.append(MTile.new(MTile.SUITS.FLOWER, i+1))
		
		CharacterInfo.TYPES.SICHUAN:
			for i in [MTile.SUITS.PIN, MTile.SUITS.SOU]:
				for j in 9:
					for k in 4:
						var a = MTile.new(i,j+1)
						tile_data.append(a)
	
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
			if next.suit == MTile.SUITS.FLOWER:
				continue
			if next.suit == MTile.SUITS.SPECIAL and [MTile.SPECIALS.KIN, MTile.SPECIALS.SEI, MTile.SPECIALS.UP].has(next.value):
				continue
			if next.unique_type != MTile.UNIQUE.NOT:
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
	
	tile_counts.add(tile.get_id())
	
	emit_signal("updated")

func remove_tile(tile: MTile):
	var t = tile_data.find(tile)
	tile_counts.add(tile.get_id(), -1)
	assert(t != -1)
	tile_data.remove_at(t)

#  add a number of flowers/seasons, minimizing seen tiles.
# lowkey probably overengineered lol
func add_flowers(count: int, season: bool):
	var offset = 5 if season else 1
	
	# find the first tile with less. wrap back to the beginning if all the same
	var next_index = 0
	var min = tile_counts.at(MTile.gen_id(MTile.SUITS.FLOWER, next_index+offset))
	for i in 4:
		next_index += 1
		if tile_counts.at(MTile.gen_id(MTile.SUITS.FLOWER, next_index+offset)) < min:
			break
	
	for i in count:
		increment_tile(MTile.new(MTile.SUITS.FLOWER, (next_index%4)+offset))
		next_index += 1


func set_color(tile: MTile, color: int):
	
	tile.canon_tile.color = color
	
	emit_signal("updated")



func load_cfg(config: ConfigFile):
	tile_data = MTileStringConverter.str_to_mtile(config.get_value("state", "tile_data"))
	emit_signal("updated")
func save_cfg(config: ConfigFile):
	config.set_value("state", "tile_data", MTileStringConverter.mtile_to_str(tile_data))
