extends Node
class_name ScoringInfo

class Han:
	var nam: String = ""
	var han: int = 0
	var desc: String = ""
	var count: int = 1 # for things like dora that can be
	# obtained multiple times
	
	func compare(a: Han, b: Han):
		if a.han < b.han:
			return true
		return false
	
	func _init(_name: String, _han: int, _desc: String):
		nam = _name
		han = _han
		desc = _desc
	
	func duplicate():
		return Han.new(nam, han, desc)

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




var fus = []
var hans = []

func get_total_han() -> int:
	var ret = 0
	for h in hans:
		ret += h.han * h.count
	return ret

func get_total_fu() -> int:
	var ret = 0
	for f in fus:
		ret += f.fu
		if f.nam == "Chiitoitsu":
			return 25
	return round_to_place(ret, 10)

const MANGAN_HANS = {
	6: 3000, # haneman
	7: 3000, #3500, # taihanman
	
	8: 4000, # baimain
	9: 4000, #4666, # shoubaiman
	10: 4000, #5333, # daibaiman
	
	11: 6000, # sanbaiman
	12: 6000, #7000, # sanhanbaiman
}

func get_base_points():
	var han = get_total_han()
	
	var points = int(get_total_fu() * pow(2.0, han + 2.0))
	
	if points >= 2000:
		points = 2000
		
		if MANGAN_HANS.has(han):
			points = MANGAN_HANS[han]
		if han >= 13:
			#points = 8000 #+ (han-13) * 500
			points = (int(han/13)+1) * 8000
		
		
	return points

func pinfu_check():
	for f in fus:
		if f.fu > 0 and !["Base", "Kan Dora", "Ura Dora", "Aka Dora", "Menzenkafu"].has(f.nam):
			return false
	return true

static func round_to_place(val, place: int) -> int:
	return ceili(val / float(place)) * place
