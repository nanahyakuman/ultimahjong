extends TextureButton
class_name Purchaseable

@onready var h_box_container = $HBoxContainer
@export var tile_graphic = preload("res://TileGraphic.tscn")

var type = null
var tile_ids = []
var cost = 3

func _ready():
	connect("pressed", _on_pressed)

func assign_tile_ids(ids: Array):
	tile_ids = ids
	
	for c in h_box_container.get_children():
		c.queue_free()
	for id in tile_ids:
		var t = tile_graphic.instantiate()
		h_box_container.add_child(t)
		t.assign_suit_value(MTile.tile_from_id(id))
		t.assign_visible_side(-1)
	#text = "aka-fy " + str(tile_ids)

func assign_type(ty: int):
	type = ty
	## sprite code

func _on_pressed():
	if get_parent().pressed(self):
		queue_free()
