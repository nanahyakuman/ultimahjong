##  tiny class that converts UNROUNDED base points
## into actual score awarded. prob doesnt need to be
## its own class but wasnt anywhere else i wanted to
## put it.
extends Resource
class_name MultiplierInfo

var dealer: bool = false
var tsumo: bool = false

func _init(was_dealer: bool, was_tsumo: bool):
	dealer = was_dealer
	tsumo = was_tsumo

# new scoring doesn't care about rounding
func get_multiplied(points):
	if !tsumo:
		return ScoringInfo.round_to_place(points * (4 if !dealer else 6), 100)
	else:
		if !dealer:
			return ScoringInfo.round_to_place(points, 100) * 2 + ScoringInfo.round_to_place(points * 2, 100)
		else:
			return ScoringInfo.round_to_place(points * 2, 100) * 3
	
	#return points * (4 if !dealer else 6)

func get_multiplier():
	return (4 if !dealer else 6)
