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
	
	func compare(a: Han, b: Han):
		if a.han < b.han:
			return true
		return false
	
	func _init(_key: String, _han: int, _penalty: int, _graphic_desc: String = ""):
		TR_KEY = _key
		nam = tr(_key)
		closed_han = _han
		open_penalty = _penalty
		graphic_desc = _graphic_desc
	
	func duplicate():
		return Han.new(TR_KEY, closed_han, open_penalty, graphic_desc)
	
	func calc_han(open: bool):
		return maxi(0, closed_han - (open_penalty * int(open))) * count

class Fu:
	var nam: String = ""
	var fu = 0
	
	# only used by gui
	var times_upgraded = 0
	
	func _init(_name: String, _fu):
		nam = tr(_name)
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
			return 25
	return ret

#const MANGAN_HANS = {
#	6: 3000, # haneman
#	7: 3000, #3500, # taihanman
#
#	8: 4000, # baimain
#	9: 4000, #4666, # shoubaiman
#	10: 4000, #5333, # daibaiman
#
#	11: 6000, # sanbaiman
#	12: 6000, #7000, # sanhanbaiman
#}
#const MANGAN_SMOOTHED = {
#	5: 2500,
#	6: 3000, # haneman
#	7: 3500, # taihanman
#
#	8: 4000, # baimain
#	9: 4666, # shoubaiman
#	10: 5333, # daibaiman
#
#	11: 6000, # sanbaiman
#	12: 7000, # sanhanbaiman
#}

#  using alt rn. to canonize, formally remove futei and set
# menzentsumo to 8
func get_base_points():
	var han = get_total_han()
	var fu = get_total_fu()
	var yakuman = get_total_yakuman()
	
	return ScoringInfo._alt_points_count(fu, han, yakuman)

#static func _base_point_calc(fu: int, han: int):
#	var points = int(round_to_place(fu,10) * pow(2.0, han + 2.0))
#
#	if points >= 2000:
#		points = 2000
#
#		if MANGAN_HANS.has(han):
#			points = MANGAN_HANS[han]
#		if han >= 13:
#			#points = 8000 #+ (han-13) * 500
#			points = (int(han/13)) * 8000
#
#	return points


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

func pinfu_check():
	for f in fus:
		if f.fu > 0 and !["Base", "Ao Dora", "Menzenkafu"].has(f.nam):
			return false
	return true

static func round_to_place(val, place: int) -> int:
	return ceili(val / float(place)) * place

static func floor_to_place(val, place: int) -> int:
	return floori(val / float(place)) * place
