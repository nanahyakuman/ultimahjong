extends HBoxContainer

@onready var label = $PanelContainer2/Label
@onready var points_label = $PanelContainer/PointsLabel
@onready var upgrade_holder = $Control/VBoxContainer/UpgradeHolder


@export var _string = ""
@export var upgrade_png = preload("res://image/fu_upgrade.png")

func set_string(strin: String, fu: int):
	_string = strin
	label.text = strin + ":"
	points_label.text = str(fu)

func set_upgrade_count(upgrades: int):
	for c in upgrade_holder.get_children():
		c.queue_free()
	for i in upgrades:
		var a = TextureRect.new()
		a.stretch_mode = TextureRect.STRETCH_KEEP
		a.texture = upgrade_png
		upgrade_holder.add_child(a)
