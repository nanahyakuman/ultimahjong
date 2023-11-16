## converts between mtiles and a readable formatted string.
extends Resource
class_name MTileStringConverter

const SUITS = {MTile.SUITS.MAN: "m", MTile.SUITS.PIN: "p", MTile.SUITS.SOU: "s", MTile.SUITS.SPECIAL: "", MTile.SUITS.FLOWER: "f", null: ""}
const SPECIALS_BY_VALUE = ["?", "東", "南", "西", "北", "登", "白", "發", "中", "金"]

#  assumes the tiles are sorted. (techincally doesn't but
# will return a dopey looking string if they're not)
static func mtile_to_str(tiles: Array) -> String:
	var ret = ""
	
	var prev_suit = null
	for t in tiles:
		if t.suit != prev_suit:
			ret += SUITS[prev_suit]
		prev_suit = t.suit
		
		if t.suit != MTile.SUITS.SPECIAL:
			ret += str(t.value)
		else:
			ret += SPECIALS_BY_VALUE[t.value]
		
		if t.aka:
			ret += "'"
	
	ret += SUITS[prev_suit]
	
	return ret

static func str_to_mtile(str: String) -> Array:
	var ret = []
	var vals = []
	
	for c in str:
		# if numeral, append to stack
		var num = int(c)
		if 1 <= num and num <= 9:
			vals.append(MTile.new(MTile.SUITS.NONE, num))
			continue
		
		# mpsf retroactive suiting
		var suit = SUITS.find_key(c)
		if suit:
			for v in vals:
				v.suit = suit
			ret.append_array(vals)
			vals.clear()
			continue
		
		# specials
		var special_value = SPECIALS_BY_VALUE.find(c)
		if special_value:
			ret.append(MTile.new(MTile.SUITS.SPECIAL, special_value))
			continue
		
		# aka
		if c == "'":
			vals[-1].aka = true
			continue
		
		if c == " ":
			continue
		
		assert(false, "Could not parse string \"%s\", failed at character \'%s\'" %[str, c])
	
	
	return ret
