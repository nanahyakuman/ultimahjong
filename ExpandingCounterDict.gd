extends Resource
class_name ExpandingCounterDict

var counts: Dictionary = {}

func add(item, amount: int = 1):
	if counts.has(item):
		counts[item] += amount
	else:
		counts[item] = amount

func at(item):
	if !counts.has(item):
		return 0
	else:
		return counts[item]

# return array of all present counts greater than a value
func get_count_greater_than(min: int) -> Array:
	var ret = []
	for c in counts.keys():
		if counts[c] > min:
			ret.append(c)
	return ret
