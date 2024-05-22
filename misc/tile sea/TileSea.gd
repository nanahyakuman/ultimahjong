extends Control

@onready var grid_container = $GridContainer

var counter = 0.0
var FREQ = 1.0/6.0

func _ready():
	for c in grid_container.get_children():
		randomize_tile(c)

func _process(delta: float):
	counter += delta
	while counter > FREQ:
		counter -= FREQ * randf_range(1.0, 2.0)
		
		var c = grid_container.get_child(randi()%grid_container.get_child_count())
		randomize_tile(c)


func randomize_tile(c: TileGraphic):
	var suit = randi()%5
	var real_suit = [1,2,4,16,32][suit]
	if real_suit == 32:
		suit = randi()%5
		real_suit = [1,2,4,16,32][suit]
	var val = (randi()%(9 if real_suit != 32 else 8))+1
	var col = 0
	if randi()%3 == 0 and (real_suit != 32 and (real_suit != 16 and val != 9)):
		col = randi()%6
	var tile = MTile.new(real_suit, val, col)
	c.assign_tile(tile)
