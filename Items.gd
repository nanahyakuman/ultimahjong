extends HBoxContainer
@onready var mana_bar = $"../ManaBar"

func tile_drawn(amount: int = 1):
	mana_bar.add_mana(amount)
