extends HBoxContainer

@onready var tile_select_label = $PanelContainer/TileSelectLabel

func _ready():
	update_text("")

func update_text(message: String):
	tile_select_label.text = message
	visible = message != ""
