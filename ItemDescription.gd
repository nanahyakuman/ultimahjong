extends PanelContainer

@onready var label = $VBoxContainer/Label
@onready var panel_container = $VBoxContainer/PanelContainer

func animate_in():
	visible = true
	
#	label.visible = false
#	panel_container.visible = false
#
#	await AnimTimer.start_get(0.06)
#	label.visible = true
#	await AnimTimer.start_get(0.02)
#	panel_container.visible = true

func animate_out():
	visible = false
