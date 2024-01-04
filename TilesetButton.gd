extends Button

@export var tileset: Texture2D

func _ready():
	if tileset == TileGraphicKnower.tileset:
		button_pressed = true

func _pressed():
	TileGraphicKnower.new_texture(tileset)
	
	for s in get_parent().get_children():
		if s == self:
			continue
		else:
			s.button_pressed = false
