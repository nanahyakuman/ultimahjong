class_name MTile

# this needs to stay a bitmask or a lot of stuff will break!
enum SUITS {NONE=0, PIN=1, SOU=2, MAN=4, CHO=8, SPECIAL=16, FLOWER=32}
# specials are 1-indexed becuase so are the suits
enum SPECIALS {NONE, EAST, SOUTH, WEST, NORTH, UP, HAKU, HATSU, CHUN, KIN, SEI}
const DEF_SPECIALS = [SPECIALS.EAST, SPECIALS.SOUTH, SPECIALS.WEST, SPECIALS.NORTH, SPECIALS.HAKU, SPECIALS.HATSU, SPECIALS.CHUN]

# for easy lookup with `has()`
const NUMERALS = [SUITS.MAN, SUITS.PIN, SUITS.SOU, SUITS.CHO]
const DRAGONS = [SPECIALS.HAKU, SPECIALS.HATSU, SPECIALS.CHUN, SPECIALS.KIN, SPECIALS.SEI]
const BASIC_DRAGONS = [SPECIALS.HAKU, SPECIALS.HATSU, SPECIALS.CHUN]
const WINDS = [SPECIALS.EAST, SPECIALS.SOUTH, SPECIALS.WEST, SPECIALS.NORTH, SPECIALS.UP]
const BASIC_WINDS = [SPECIALS.EAST, SPECIALS.SOUTH, SPECIALS.WEST, SPECIALS.NORTH]
# here for consitency, the sou in ryuuiisou
const RYUUII_VALUES = [2,3,4,6,8]

# tr strings to generate human readable name
const SUIT_NAMES = ["TILE_SUIT_PIN", "TILE_SUIT_SOU", "TILE_SUIT_MAN", "TILE_SUIT_CHO", "nope", "TILE_SUIT_FLOWER"]
const SPECIAL_NAMES = ["NONE", "TILE_SPEC_EAST", "TILE_SPEC_SOUTH", "TILE_SPEC_WEST", "TILE_SPEC_NORTH", "TILE_SPEC_UP", "TILE_SPEC_HAKU", "TILE_SPEC_HATSU", "TILE_SPEC_CHUN", "TILE_SPEC_KIN"]

var suit: int
var value: int

enum COLS {NONE, AKA, AO, KIN, MURASAKI, MIDORI, KURO}
var color: int
# for verbosity, the translation strings for the dora
const COLOR_TR_STRINGS = ["NO COLOR", "GUIDE_TILES_AKA_DORA", "GUIDE_TILES_AO_DORA", "GUIDE_TILES_KIN_DORA", "GUIDE_TILES_MURASAKI_DORA", "GUIDE_TILES_MIDORI_DORA", "GUIDE_TILES_KURO_DORA"]

enum MATS {NONE, CERAMIC, METAL, VERDANT, FRAME, KEBAB}
var material: int
const MAT_TR_STRINGS = ["NO MATERIAL", "GUIDE_TILES_MAT_CERAMIC", "GUIDE_TILES_MAT_METAL", "GUIDE_TILES_MAT_VERDANT", "GUIDE_TILES_MAT_FRAME", "GUIDE_TILES_MAT_KEBAB" ]

#  whether the tile has a pocchi
var pocchi: bool

#  allows for more bespoke tile types, like d6 or dominoes. these should define custom draw
# behavoir most of the time, but that'll occur in `TileGraphic.tscn`, not here.
#  note that being unique does NOT imply a certain suit/value on its own! any tile can
# theoretically be an eraser and will draw as such, so you need to keep the suit/value in sync!
enum UNIQUE {NOT = 0, D6, ERASER, DOMINO}
var unique_type = UNIQUE.NOT
# tracker that makes it so you can only do special item things once a round
var already_used = false
# so that unique tiles can store custom arguments. keep this reference updated:
# 	DOMINO
#		[0] is the other value
var unique_args = []


# metadata so we can blur out siebar tiles we've discarded
var discarded = false

func _init(s:int, v:int, col:int = COLS.NONE, mat: int = MATS.NONE, p = false, u = UNIQUE.NOT, ua = []):
	suit = s
	value = v
	color = col #randi()%7 if randi()%4==0 else 0
	material = mat #randi()%6 if randi()%4==0 else 0
	pocchi = p
	unique_type = u
	unique_args = ua.duplicate(true)

#  assign a tile onto an existing one, for convenience
func assign_tile(new: MTile):
	suit = new.suit
	value = new.value
	color = new.color
	material = new.material
	pocchi = new.pocchi
	unique_type = new.unique_type
	unique_args = new.unique_args.duplicate(true)

#  for comparision that doesnt care about specific flags, just value.
# an aka 5p equals a colorless 5p with this as the comparee.
func get_id():
	return MTile.gen_id(suit, value)

func get_name():
	# had to destaticify this, keeping this as an alias
	#return MTile.gen_name(self)
	return gen_name(self)


#  `chi_sets` returns neighbors and superneighbors in order, to make
# it easy to check for chis.
func get_adj_ids(s = suit, v = value, chi_sets = false):
	if suit == SUITS.SPECIAL or suit == SUITS.FLOWER:
		return []
	else:
		if !chi_sets:
			return [MTile.gen_id(s, v-1), MTile.gen_id(s, v+1)]
		else:
			return [MTile.gen_id(s, v-2), MTile.gen_id(s, v-1), MTile.gen_id(s, v+1), MTile.gen_id(s, v+2)]

func get_dora_id():
	var val = []
	if suit == SUITS.SPECIAL:
		match value:
			SPECIALS.EAST:
				val.append(SPECIALS.SOUTH)
			SPECIALS.SOUTH:
				val.append(SPECIALS.WEST)
			SPECIALS.WEST:
				val.append(SPECIALS.NORTH)
			SPECIALS.NORTH:
				val.append(SPECIALS.EAST)
			SPECIALS.HAKU:
				val.append(SPECIALS.HATSU)
			SPECIALS.HATSU:
				val.append(SPECIALS.CHUN)
			SPECIALS.CHUN:
				val.append(SPECIALS.HAKU)
			SPECIALS.KIN:
				val += [SPECIALS.HAKU, SPECIALS.HATSU, SPECIALS.CHUN]
			SPECIALS.UP:
				val += [SPECIALS.UP]
	elif suit == SUITS.FLOWER:
		pass
	else:
		val.append((((value + 1) - 1) % 9) + 1)
	
	var ret = []
	for v in val:
		ret.append(MTile.gen_id(suit, v))
	return ret

# does not care about color or canon, so two different 5p are "equal"
static func gen_id(s: int, v: int):
	return s * 100 + v * 1

static func tile_from_id(id: int) -> MTile:
	return MTile.new(int(id/100), id%100)

#  ordered so that better dora are always first among equals, unique items
# are always last. this means on calls we take the best dora first, and special
# items last.
static func gen_order(t: MTile):
	return gen_id(t.suit,t.value) * 100 + (90 - t.color * 10) + (int(t.unique_type != MTile.UNIQUE.NOT))

static func tile_compare(a:MTile, b:MTile):
	return gen_order(a) < gen_order(b)

# not static anymore becaise tr() is not-static
func gen_name(tile: MTile):
	var str
	
	# base name
	if tile.suit == SUITS.SPECIAL:
		str = tr(SPECIAL_NAMES[tile.value])
	else:
		str = str(tile.value) + tr(SUIT_NAMES[log(tile.suit)/log(2)])
	
	# color desc
	if tile.color != COLS.NONE:
		str += "\n" + tr(COLOR_TR_STRINGS[tile.color])
	
	# material desc
	if tile.material != MATS.NONE:
		str += "\n" + tr(MAT_TR_STRINGS[tile.material])
	
	return str


#  called if this tile is right clicked on. only need to define
# behavior if it exists, `_` should catch things like eraser that
# do nothing.
#  returns whether there were any updates or not
func try_unique()-> bool:
	if already_used:
		return false
	match unique_type:
		UNIQUE.D6:
			value = (randi()%6)+1
			already_used = true
			return true
		_:
			return false
