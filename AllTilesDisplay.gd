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
	for str in ["Sou", "Man", "Cho", "Special", "Flowers"]:
		var a = suits_root.get_child(0).duplicate()
		a.name = str
		suits_root.add_child(a)
		suit_holders.append(a)

func update():
	for sh in suit_holders:
		for s in sh.get_children():
			for c in s.get_children():
				c.queue_free()
	
	for t in tile_counter.tile_data:
		add_tile_graphic(t)


func add_tile_graphic(t: MTile):
	var suit_index = int(log(t.suit)/log(2))
	var current_suit_holder = suit_holders[suit_index]
	
	# dynamically expand
	while current_suit_holder.get_child_count() < t.value:
		var dupe = current_suit_holder.get_child(0).duplicate(0)
		for dc in dupe.get_children():
			dc.queue_free()
		current_suit_holder.add_child(dupe)
	
	# add the tile
	var tg = tile_graphic.instantiate()
	var col = current_suit_holder.get_child(t.value-1)
	col.add_child(tg)
	tg.assign_tile(t)




