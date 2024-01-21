extends Control
class_name Purchaseable

@onready var tile_container = $HBoxContainer/TileContainer
@export var tile_graphic = preload("res://TileGraphic.tscn")
@export var item_scene = preload("res://item.tscn")
@export var upgrade_scene = preload("res://upgrade.tscn")
@onready var sprite = $HBoxContainer/TextureHolder/Sprite2D
@onready var label = $PanelBuster/Label


enum TYPES {AKA, AO, KIN, ITEM, UPGRADE}
const HOVER_TEXTS = ["Convert tiles to aka.", "Convert tiles to ao.", "Convert tiles to kin."]
var type = null
# should only possess one either tiles or item or upgrade
var tiles = []
var hidden_mask = []
var item: Item
var upgrade: Upgrade
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
		tg.mouse_filter = MOUSE_FILTER_PASS
		tg.assign_tile(tiles[i])
		if hidden_mask[i]:
			tg.set_reversed(true)
		tg.assign_visible_side(-1)

func assign_item(id: int, charge: int):
	item = item_scene.instantiate()
	item.type = id
	item.charge_type = charge
	tile_container.add_child(item)
	# force the item to show up nicely.
	item.set_shop_graphics()

func assign_upgrade(id: int):
	upgrade = upgrade_scene.instantiate()
	upgrade.type = id
	tile_container.add_child(upgrade)

func assign_type(ty: int):
	type = ty
	sprite.frame = ty

func calc_cost():
	if type == TYPES.AKA:
		cost = 2
#	elif type == TYPES.ADD:
#		cost = 1
#	elif type == TYPES.DEAD_REDUCE:
#		cost = 1
#	elif type == TYPES.KAN_REVEAL:
#		cost = 3
	elif type == TYPES.ITEM:
		match item.charge_type:
			Item.CH_TYPES.ONCE:
				cost = 1
			Item.CH_TYPES.MANA:
				cost = 3
			Item.CH_TYPES.TIMR:
				cost = 4
	elif type == TYPES.UPGRADE:
		# tune this in future
		cost = 2
	
	label.text = "%d" % cost


#  parent deals with it. kinda gross ngl, i think was in a caffeine daze when i wrote
# all this, but it aint broke.
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
