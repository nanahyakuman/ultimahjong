extends HBoxContainer

@onready var label = $Label
@onready var points_label = $PointsLabel

@export var _string = ""

func set_string(strin: String, yakufu: Node):
	_string = strin
	label.text = strin + ":"
	points_label.text = str(yakufu.FU[strin].fu)
