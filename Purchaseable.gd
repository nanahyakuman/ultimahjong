extends Control
class_name Purchaseable

@onready var tile_container = $HBoxContainer/TileContainer
@export var tile_graphic = preload("res://TileGraphic.tscn")
@export var item_scene = preload("res://item.tscn")
@export var upgrade_scene = preload("res://upgrade.tscn")
# hidden unless we're a recolor purchaseable
@onready var texture_holder = $HBoxContainer/TextureHolder
@onready var sprite = $HBoxContainer/TextureHolder/Sprite2D
@onready var label = $PanelBuster/Label


enum TYPES {COLOR, ITEM, UPGRADE, MATERIAL}
var type = null
# should only possess one either tiles or item or upgrade
var tiles = []
var hidden_mask = []
var item: Item
var upgrade: Upgrade
var cost = 3
# only used by color/material purchaseables
var color_or_material = MTile.COLS.NONE

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
	texture_holder.visible = ty == TYPES.COLOR or ty == TYPES.MATERIAL
	sprite.frame_coords = Vector2i(color_or_material, int(ty == TYPES.MATERIAL))

func calc_cost():
	if type == TYPES.COLOR:
		cost = 0
	elif type == TYPES.MATERIAL:
		cost = 0
	elif type == TYPES.ITEM:
		match item.charge_type:
			Item.CH_TYPES.ONCE:
				cost = 1
			Item.CH_TYPES.MANA:
				cost = 2
			Item.CH_TYPES.TIMR:
				cost = 4
	elif type == TYPES.UPGRADE:
		cost = Upgrade.METADATA[upgrade.type][Upgrade.METADATA_COST]
	
	label.text = "%d" % cost


#  parent deals with it. kinda gross ngl, i think was in a caffeine daze when i wrote
# all this, but it aint broke.
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if await get_parent().pressed(self):
				_mouse_exit()
				queue_free()


func _mouse_entered():
	if type == TYPES.COLOR:
		CursorText.set_text(tr("PURCHASEABLE_RECOLOR") + "\n " + tr(MTile.COLOR_TR_STRINGS[color_or_material]))
	elif type == TYPES.MATERIAL:
		CursorText.set_text(tr("PURCHASEABLE_REMAT") + "\n " + tr(MTile.MAT_TR_STRINGS[color_or_material]))

func _mouse_exit():
	CursorText.set_text("")
