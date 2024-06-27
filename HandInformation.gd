##  simple wrapper for hand information, used in scoring
extends Resource
class_name HandInformation

var hand: Array = []
var tsumo: MTile = null
var already_made_groupings: Array = [] # of `Groupings`
var most_recent_discard: MTile = null # ignored if tsumo is defined

func get_all_tiles():
	var ret = hand.duplicate()
	if tsumo:
		ret += [tsumo]
	for amg in already_made_groupings:
		ret.append_array(amg)
	return ret
