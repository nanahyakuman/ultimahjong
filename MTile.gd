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

# to generate human readable name
const SUIT_NAMES = ["-Pin", "-Sou", "-Man", "-Cho", "-Spec", "-Flower"]
const SPECIAL_NAMES = ["NONE", "East", "South", "West", "North", "Rising", "White", "Green", "Red", "Gold"]

var suit: int
var value: int

enum {COL_NONE, COL_AKA, COL_AO, COL_KIN, COL_MURASAKI, COL_MIDORI}
var color: int

#  whether the tile has a pocchi
var pocchi: bool

#  allows us to track tiles that have been modified so the player can still
# sorta count them. this is different from the canon tile, which is the canonical
# form shown in the sidebar. if you temp shift a 6s to a 7s and permanantly pocchi it,
# there will be pocchi'd 7s this round, but the canong change was pocchi'ing a 6s, so
# starting next round there'll be a pocchi'd 6s in the wall. this is possibly all too much
# but i want there to be both temp and permanent changes and this is the logical way to do that.
var former: MTile

#  allow tiles in round use to point back to their canon originator in
# `TileCounter` so that permanent mods are easier to make
var canon_tile: MTile

#  allows for more bespoke tile types, like d6 or dominoes. these should define custom draw
# behavoir most of the time, but that'll occur in `TileGraphic.tscn`, not here.
#  note that being unique does NOT imply a certain suit/value on its own! any tile can
# be an eraser and will draw as such.
enum UNIQUE {NOT = 0, D6, ERASER, DOMINO}
var unique_type = UNIQUE.NOT
# tracker that makes it so you can only do special item things once a round
var already_used = false
# so that unique tiles can store custom arguments. keep this reference updated:
# 	DOMINO
#		[0] is the other value
var unique_args = []

func _init(s:int, v:int, col:int = COL_NONE, f = null, p = false, c = null, u = UNIQUE.NOT, ua = []):
	suit = s
	value = v
	color = col
	former = f
	pocchi = p
	canon_tile = c
	unique_type = u
	unique_args = ua.duplicate(true)

#  called on canon tiles to rewrite their settings. this feels a little bad
# but it's necessary bc of how godot does pointers
func assign_tile(new: MTile):
	suit = new.suit
	value = new.value
	color = new.color
	former = new.former
	pocchi = new.pocchi
	canon_tile = null
	unique_type = new.unique_type
	unique_args = new.unique_args.duplicate(true)

# duplicate and save self as new tile's "canon" tile
func duplicate_canonize() -> MTile:
	return MTile.new(suit, value, color, former, pocchi, self, unique_type, unique_args)

# just duplicate
func duplicate() -> MTile:
	return MTile.new(suit, value, color, former, pocchi, canon_tile, unique_type, unique_args)

#  for comparision that doesnt care about specific flags, just value.
# an aka 5p equals a colorless 5p with this as the comparee.
func get_id():
	return MTile.gen_id(suit, value)

func get_name():
	return MTile.gen_name(self)

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

static func gen_name(tile: MTile):
	if tile.suit == SUITS.SPECIAL:
		return SPECIAL_NAMES[tile.value]
	else:
		return str(tile.value) + SUIT_NAMES[log(tile.suit)/log(2)]


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
			canon_tile.value = value
			already_used = true
			return true
		_:
			return false
