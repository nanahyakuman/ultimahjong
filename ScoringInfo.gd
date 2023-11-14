extends Node
class_name ScoringInfo

class Han:
	var nam: String = ""
	var han: int = 0
	var desc: String = ""
	
	func compare(a: Han, b: Han):
		if a.han < b.han:
			return true
		return false
	
	func _init(_name: String, _han: int, _desc: String):
		nam = _name
		han = _han
		desc = _desc

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
		ret += h.han
	return ret

func get_total_fu() -> int:
	var ret = 0
	for f in fus:
		ret += f.fu
	return ret

func get_total_points():
	var points = int(get_total_fu() * pow(2.0, get_total_han() + 2.0))
	points = ceili(points / 100.0) * 100
	return points

func pinfu_check():
	for f in fus:
		if f.fu > 0 and !["Base", "Kan Dora", "Ura Dora", "Aka Dora"].has(f.nam):
			return false
	return true
