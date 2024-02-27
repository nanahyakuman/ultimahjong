extends Control

@onready var grid_container = $GridContainer

func _ready():
	for c in grid_container.get_children():
		var suit = randi()%5
		var real_suit = [1,2,4,16,32][suit]
		if real_suit == 32:
			suit = randi()%5
			real_suit = [1,2,4,16,32][suit]
		var val = (randi()%(9 if real_suit != 32 else 8))+1
		var col = 0
		if randi()%4 == 0 and (real_suit != 32 and (real_suit != 16 and val != 9)):
			col = randi()%4
		var tile = MTile.new(real_suit, val, col)
		c.assign_tile(tile)
