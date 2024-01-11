extends TextureButton

@onready var character_select = $"../../../.."

@export var offset = -1

func _pressed():
	character_select.change_char(character_select.char_info.type + offset)
