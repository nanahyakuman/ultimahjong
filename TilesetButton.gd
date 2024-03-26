extends Button

@export var val = 0

#func _ready():
#	if tileset == TileGraphicKnower.tileset:
#		button_pressed = true

func _pressed():
	TileGraphicKnower.new_texture(val)
	
	for s in get_parent().get_children():
		if s == self:
			s.button_pressed = true
		else:
			s.button_pressed = false
	
	release_focus()
