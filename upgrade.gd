##  persistant upgrades. structured weirdwsly because its a mix of gutted purchaseable
## code and gutted item code.
extends CursorTextRequester
class_name Upgrade

# probably gonna need to pool these so you dont get dupes
enum TYPES {UPR_NONE, UPR_DEAD_REDUCE, UPR_KAN_REVEAL, UPR_KITA}
var type = TYPES.UPR_NONE

func _ready():
	super._ready()
	
	# hacky but works
	var string_id = TYPES.keys()[type]
	hover_text = tr(string_id)


# called when bought. (and on reload??)
func bought(upgrades: Upgrades):
	match type:
		TYPES.UPR_NONE:
			assert(false, "not a valid upgrade!")
		TYPES.UPR_DEAD_REDUCE:
			upgrades.dead_wall_size_reduce += 4
		TYPES.UPR_KAN_REVEAL:
			upgrades.additional_revealed_kandora += 1
		TYPES.UPR_KITA:
			upgrades.can_kita_nuki = true
