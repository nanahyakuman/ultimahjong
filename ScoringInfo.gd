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
	var fu: int = 0
	
	func _init(_name: String, _fu: int):
		nam = _name
		fu = _fu


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
