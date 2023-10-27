extends Control
class_name Purchaseable

@onready var tile_container = $HBoxContainer/TileContainer
@export var tile_graphic = preload("res://TileGraphic.tscn")
@onready var rich_text_label = $PanelBuster/RichTextLabel
@onready var sprite = $HBoxContainer/TextureHolder/Sprite2D

enum TYPES {AKA, ADD}
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
		tg.assign_suit_value(tiles[i])
		if hidden_mask[i]:
			tg.set_reversed(true)
		tg.assign_visible_side(-1)

func assign_type(ty: int):
	type = ty
	sprite.frame = ty

# calc cost based on what is shown. call AFTER assigning type!
func calc_cost():
	cost = 0.0
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
	
	rich_text_label.clear()
	rich_text_label.append_text("%d" % cost)


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if get_parent().pressed(self):
				queue_free()
