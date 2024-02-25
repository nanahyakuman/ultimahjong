extends HBoxContainer
@onready var color_rect = $ColorRect
@onready var label = $Label

func set_color(col: Color):
	color_rect.color = col

func set_text(str: String):
	label.text = str
