extends Control
class_name Purchaseable

@onready var tile_container = $HBoxContainer/TileContainer
@export var tile_graphic = preload("res://TileGraphic.tscn")
@onready var sprite = $HBoxContainer/TextureHolder/Sprite2D
@onready var label = $PanelBuster/Label

enum TYPES {AKA, ADD, DEAD_REDUCE, KAN_REVEAL}
const HOVER_TEXTS = ["Convert tiles to aka.", "Add tiles to wall.", "Reduce the number of tiles killed at the start of a round.", "Start with additional kan dora revealed."]
var type = null
var tiles = []
var hidden_mask = []
var cost = 3


func assign_tiles(ts: Array, hidden: int = 0):
	tiles = ts
	
	for c in tile_container.get_children():
		c.queue_free()
	
	# create an array mask to hide random tiles
	hidden_mask = []
	hidden_mask.resize(ts.size())
	for i in mini(hidden_mask.size(), hidden):
		hidden_mask[i] = 1
	hidden_mask.shuffle()
	
	for i in tiles.size():
		var tg = tile_graphic.instantiate()
		tile_container.add_child(tg)
		tg.assign_tile(tiles[i])
		if hidden_mask[i]:
			tg.set_reversed(true)
		tg.assign_visible_side(-1)

func assign_type(ty: int):
	type = ty
	sprite.frame = ty

# calc cost based on what is shown. call AFTER assigning type!
func calc_cost():
	if type == TYPES.AKA or type == TYPES.ADD:
		cost = 0
		for i in tiles.size():
			if hidden_mask[i]:
				cost += 2
			elif tiles[i].suit == MTile.SUITS.SPECIAL:
				if MTile.DRAGONS.has(tiles[i].value):
					cost += 5
				else:
					cost += 4
			else:
				cost += 3
		
		if type == TYPES.ADD:
			cost /= 2
		
		cost = floori(cost)
	elif type == TYPES.DEAD_REDUCE:
		cost = 3
	elif type == TYPES.KAN_REVEAL:
		cost = 6
	
	label.text = "%d" % cost


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if await get_parent().pressed(self):
				get_parent().hovered(self, false)
				queue_free()
	
func _mouse_entered():
	get_parent().hovered(self, true)

func _mouse_exit():
	get_parent().hovered(self, false)
