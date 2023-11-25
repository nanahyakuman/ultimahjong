##  creates displays for all the tiles in hand dynamically.
## could probably take an optimizaiton pass or two.
extends PanelContainer

@onready var tile_counter = $"../../../../../../../MahjongRoot/MahjongManager/TileCounter"
@onready var suits_root = $ScrollContainer/SuitsRoot

@export var tile_graphic = preload("res://TileGraphic.tscn")

var suit_holders = []

func _ready():
	tile_counter.connect("updated", update)
	_initialize()

func _initialize():
	suit_holders.append(suits_root.get_child(0))
	for str in ["Sou", "Man", "Special", "Flowers"]:
		var a = suits_root.get_child(0).duplicate()
		a.name = str
		suits_root.add_child(a)
		suit_holders.append(a)

func update():
	for t in tile_counter.tile_data:
		add_tile_graphic(t)

#  easier to understand if you check the scenetree as you go but we create
# vboxes for each major suit, then an hbox for the unique ids within the suit (usually 4)
func add_tile_graphic(t: MTile):
	var suit_index = int(log(t.suit)/log(2))
	var current_suit_holder = suit_holders[suit_index]
	#  dynamically expand, creating new rows as duplicates and then erasing dupe children.
	# awkward but the most scaleable solution
	while current_suit_holder.get_child_count() <= t.id:
		current_suit_holder.add_child(current_suit_holder.get_child(0).duplicate())
		for c in current_suit_holder.get_child(-1).get_children():
			c.queue_free()
	# add the tile
	var tg = tile_graphic.instantiate()
	var row = current_suit_holder.get_child(t.id)
	row.add_child(tg)
	tg.assign_tile(t)




