extends Resource
class_name ExpandingCounterDict

var counts: Dictionary = {}

func add(item):
	if counts.has(item):
		counts[item] += 1
	else:
		counts[item] = 1

# return array of all present counts greater than a value
func get_count_greater_than(min: int) -> Array:
	var ret = []
	for c in counts.keys():
		if counts[c] > min:
			ret.append(c)
	return ret
