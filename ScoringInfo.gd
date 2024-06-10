extends Resource
class_name ScoringInfo

class Han:
	# the translation key
	var TR_KEY: String = ""
	var nam: String = ""
	# you probably want `calc_han()`
	var closed_han: int = 0
	#  0 means no penalty, (n >= han) means closed only, any other
	# integer (only ever 1 in base mahjong) is a penalty.
	#  note that yakuchecker has seperate hardcoded checks for openness atm
	var open_penalty: int = 0
	# visual aid for yaku. uses the colored tiles font expecting unicode mahj tiles.
	var graphic_desc: String = ""
	#  for things like dora or yakuhai that can be obtained multiple times. only
	# really used to clean up the scoring display.
	var count: int = 1
	
	#  for marking some yaku as easy to go for for beginners
	var easy = false
	
	func compare(a: Han, b: Han):
		if a.han < b.han:
			return true
		return false
	
	func _init(_key: String, _han: int, _penalty: int, _graphic_desc: String = "", _easy: bool = false):
		TR_KEY = _key
		nam = _key
		closed_han = _han
		open_penalty = _penalty
		graphic_desc = _graphic_desc
		easy = _easy
	
	func duplicate():
		return Han.new(TR_KEY, closed_han, open_penalty, graphic_desc, easy)
	
	func calc_han(open: bool):
		return (closed_han - (open_penalty * int(open))) * maxi(0, count)

class Fu:
	var nam: String = ""
	var fu = 0
	
	# only used by gui
	var times_upgraded = 0
	
	func _init(_name: String, _fu):
		nam = _name
		fu = _fu
	
	func duplicate():
		return Fu.new(nam, fu)



var open = false
var fus = []
var hans = []

func get_total_han() -> int:
	var ret = 0
	for h in hans:
		# take open penalties into account
		ret += h.calc_han(open)
	return ret

func get_total_yakuman() -> int:
	var ret = 0
	for h in hans:
		ret += h.calc_han(open) / 13
	return ret

func get_total_fu() -> int:
	var ret = 0
	for f in fus:
		ret += f.fu
		if f.nam == "Chiitoitsu":
			return 25 # this prob shouldnt be hardcoded in future
	return ret

func get_riichi_return() -> int:
	var sum = 0
	for h in hans:
		if h.nam == "YAKU_RIICHI" or  h.nam == "YAKU_DOUBLE_RIICHI":
			sum += 1000 * h.closed_han * h.count
	return sum


func get_base_points():
	var han = get_total_han()
	var fu = get_total_fu()
	var yakuman = get_total_yakuman()
	
	return ScoringInfo._aoten_points_count(fu, han, yakuman)


static func _alt_points_count(fu: int, han: int, yakuman: int):
	var base = 250
	base += floor_to_place(fu, 10) * 10 #subtract 20 here if adding futei
	base *= pow(2, han-1)
	
	if base > 2000:
		base = 2000
		
		if han >= 5:
			base = han * 500
		if han >= 11:
			base = 5000 + (han-10) * 1000
		
		if han >= 13:
			base = 8000
			# override kazoe with other yakuman
			if yakuman >= 1:
				base = yakuman * 8000
	
	return base

# assumes futei added already. scales exponentially (too fast?)
static func _aoten_points_count(fu: int, han: int, yakuman: int):
	return float(fu) * pow(2, han+2)

# also assumes futei. scales up linearly, so 7 han is ~7700 pts
static func _linear_points_count(fu: int, han: int, yakuman: int):
	return fu * han * 250/20

#  also assumes futei, steps up through mults without ever discarding fu.
# this means that 30 fu is akin to a doubler,
const han_mults = [0, 1, 2, 4, 8, 10, 12, 14, 16, 18, 20, 24, 28, 32]
static func _stepped_points_count(fu: int, han: int, yakuman: int):
	var base = fu * 250/30
	
	base = round_to_place(base, 25)
	
	var mult
	if han <= 13:
		mult = han_mults[han]
	else:
		mult = 32
	
	return base * mult


# han are tied to mults of 1000, fu are ~400 per 10
static func _undoubled_fu_count(fu: int, han: int, yakuman: int):
	var base
	# redundant but should catch (-) vals
	if han <= 0:
		base = 0
	elif han <= 13:
		base = 250 * han_mults[han]
	else:
		# yakuman are 32k each, then normal calculations for whatevers on top
		base = 250*32 * int(han / 13) + (250 * han_mults[han%13])
	
	var fu_base = round_to_place(fu-30, 10)
	fu_base *= 10
	
	# chiitoi override. prob sohulndt be harcoded in future
	if fu == 25:
		fu_base = 250
	
	return base + fu_base


func pinfu_check():
	for f in fus:
		if f.fu > 0 and !["FU_TYPE_BASE", "FU_TYPE_AO_DORA", "FU_TYPE_MENZENKAFU", "FU_TYPE_TSUMO"].has(f.nam):
			return false
	return true

static func round_to_place(val, place: int) -> int:
	return ceili(val / float(place)) * place

static func floor_to_place(val, place: int) -> int:
	return floori(val / float(place)) * place
