extends CursorTextRequester

@onready var fill = $Fill
@onready var fill2 = $Fill2
@onready var label = $Label

@export var cap = 136/2
@export var mana = 0

func _ready():
	_update_display()
	super._ready()
	
#	add_mana(150, true)

# overcharge allows us to reach a double-cap on mana
func add_mana(amount: int, overcharge: bool = false):
	var mod = 0
	if !overcharge:
		#mana = mini(mana + amount, cap)
		mod = amount
		if mana + mod > cap:
			mod = maxi(0, cap - mana)
	else:
		mod = amount
		if mana + mod > cap * 2:
			mod = maxi(0, cap * 2 - mana)
	
	mana += mod
	
	_update_display()

func can_use_mana(amount: int) -> bool:
	return amount <= mana

# only ever called after assuring `can_use_mana()`
func use_mana(amount: int):
	mana -= amount
	_update_display()

func _update_display():
	var wid = custom_minimum_size.x
	# -2 is the texture marhgins
	fill.custom_minimum_size.x = mini(float(mana) * wid / cap, wid - 2)
	fill2.custom_minimum_size.x = mini(float(mana-cap) * wid / cap, wid - 2)
	label.text = str(mana)
