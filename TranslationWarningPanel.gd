extends PanelContainer


func _ready():
	visible = false

func _on_ja_button_toggled(button_pressed):
	visible = button_pressed
