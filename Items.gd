extends HBoxContainer
@onready var mana_bar = $"../ManaBar"

func tile_drawn(amount: int = 1):
	mana_bar.add_mana(amount)
	update_tile_graphics()

func update_tile_graphics():
	for i in get_children():
		i.update_graphics(mana_bar.mana)
