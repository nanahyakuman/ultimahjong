extends Node
class_name ScoringInfo

class Yaku:
	var nam: String = ""
	var han: int = 0
	var desc: String = ""
	
	func compare(a: Yaku, b: Yaku):
		if a.han < b.han:
			return true
		return false
	
	func _init(_name: String, _han: int, _desc: String):
		nam = _name
		han = _han
		desc = _desc


var total_han = 0
var fu = 0
var hans = []
