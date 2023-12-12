extends Control
class_name Purchaseable

@onready var tile_container = $HBoxContainer/TileContainer
@export var tile_graphic = preload("res://TileGraphic.tscn")
@export var item_scene = preload("res://item.tscn")
@onready var sprite = $HBoxContainer/TextureHolder/Sprite2D
@onready var label = $PanelBuster/Label


enum TYPES {AKA, ADD, DEAD_REDUCE, KAN_REVEAL, ITEM}
const HOVER_TEXTS = ["Convert tiles to aka.", "Add tiles to wall.", "Increase the number of tiles drawn in a round by 4.", "Start with additional kan dora revealed."]
var type = null
# should only possess one either tiles or item
var tiles = []
var hidden_mask = []
var item: Item
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

func assign_item(id: int):
	item = item_scene.instantiate()
	item.type = id
	item.charge_type = randi()%3
	tile_container.add_child(item)

func assign_type(ty: int):
	type = ty
	sprite.frame = ty

func calc_cost():
	if type == TYPES.AKA:
		cost = 2
	elif type == TYPES.ADD:
		cost = 1
	elif type == TYPES.DEAD_REDUCE:
		cost = 1
	elif type == TYPES.KAN_REVEAL:
		cost = 3
	elif type == TYPES.ITEM:
		match item.charge_type:
			Item.CH_TYPES.ONCE:
				cost = 1
			Item.CH_TYPES.MANA:
				cost = 3
			Item.CH_TYPES.TIMR:
				cost = 4
	
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
