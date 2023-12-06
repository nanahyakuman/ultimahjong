extends CursorTextRequester

@onready var fill = $Fill
@onready var label = $Label

@export var cap = 136
@export var mana = 0

func _ready():
	_update_display()
	super._ready()

func add_mana(amount: int):
	mana = mini(mana + amount, cap)
	_update_display()

func can_use_mana(amount: int) -> bool:
	return amount <= mana

# only ever called after assuring `can_use_mana()`
func use_mana(amount: int):
	mana -= amount
	_update_display()

func _update_display():
	var wid = custom_minimum_size.x
	fill.custom_minimum_size.x = mana * wid / cap
	label.text = str(mana)
