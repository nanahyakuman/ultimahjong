## converts between mtiles and a readable formatted string.
extends Object
class_name MTileStringConverter

# character or emoji based encoding
enum {CHARACTER, EMOJI}

const SUITS = {MTile.SUITS.MAN: "m", MTile.SUITS.PIN: "p", MTile.SUITS.SOU: "s", MTile.SUITS.SPECIAL: "", MTile.SUITS.FLOWER: "f", null: ""}
const SPECIALS_BY_VALUE = ["?", "東", "南", "西", "北", "登", "白", "發", "中", "金"]

const EMOJIS = [
	"🀙", "🀚", "🀛", "🀜", "🀝", "🀞", '🀟', "🀠", "🀡",
	"🀐", "🀑", "🀒", "🀓", "🀔", "🀕", "🀖", "🀗", "🀘",
	"🀇", "🀈", "🀉", "🀊", "🀋", "🀌", "🀍", "🀎", "🀏",
	"🀀", "🀁", "🀂", "🀃", "⬆️", "🀆", "🀅", "🀄", "⭐",
	"🀢", "🀣", "🀤", "🀥", "🀦", "🀧", "🀨", "🀩"
]

#  tiles should be sorted. (techincally doesn't matter but
# will return a dopey looking string if they're not)=
#  string is formatted mostly normally, but with more metadata for aka/ao/kin.
# instead of 0 meaning aka five, `5'` means red five, and this extends to any
# other number, with similar formatting for ao and kin. metadata always comes before
# suit, so `5'*p` is a red pocchi 5pin but `5'p*` is malformed. i believe we can actually
# still read it in but it is avoided.
#  additionally, we forgo the dopey 1z for east wind thing, we just write the literal
# character 發 instead.
static func mtile_to_str(tiles: Array, type = CHARACTER) -> String:
	if type == CHARACTER:
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
			
			match t.color:
				MTile.COL_AKA:
					ret += "'"
				MTile.COL_AO:
					ret += "`"
				MTile.COL_KIN:
					ret +="\""
			
			if t.pocchi:
				ret +="*"
		
		ret += SUITS[prev_suit]
		
		return ret
	else:
		var ret = ""
		for t in tiles:
			ret += EMOJIS[(log(t.suit)/log(2))*10 + t.value-1]
		return ret

static func str_to_mtile(str: String) -> Array:
	var ret = []
	var vals = []
	
	for c in str:
		# aka
		if c == "'":
			vals[-1].color = MTile.COL_AKA
			continue
		if c == "`":
			vals[-1].color = MTile.COL_AO
			continue
		if c == "\"":
			vals[-1].color = MTile.COL_KIN
			continue
		
		if c == "*":
			if vals.size() > 0:
				vals[-1].pocchi = true
			else:
				ret[-1].pocchi = true
			continue
		
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
		
		
		if c == " ":
			continue
		
		assert(false, "Could not parse string \"%s\", failed at character \'%s\'" %[str, c])
	
	
	return ret
