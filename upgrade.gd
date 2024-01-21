##  persistant upgrades. a lot of this is gutted from item code,
## but its diffrent enough i didnt think it'd be worth to abstract/inherent
extends Control
class_name Upgrade

@onready var description = $Description
@onready var hover_name = $Description/VBoxContainer/PanelContainer/HBoxContainer/PanelContainer/Name
@onready var hover_body = $Description/VBoxContainer/Label

# probably gonna need to pool these so you dont get dupes
enum TYPES {UPR_NONE, UPR_KITA}
var type = TYPES.UPR_NONE

# type is assigned before ready is called
func _ready():
	connect("mouse_entered", _mouse_entered)
	connect("mouse_exited", _mouse_exited)
	_mouse_exited()
	
	var string_id = TYPES.keys()[type]
	hover_name.text = tr(string_id)
	hover_body.clear()
	hover_body.append_text(tr(string_id + "_DESC"))

# called when bought. (and on reload??)
func bought(upgrades: Upgrades):
	pass

func _mouse_entered():
	description.animate_in()
func _mouse_exited():
	description.animate_out()
