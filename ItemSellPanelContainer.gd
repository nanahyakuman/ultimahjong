extends PanelContainer

@onready var label = $Label

var on = false

func animate_in():
	visible = true
	
	label.text = ""
	await AnimTimer.start_get(.05)
	label.text = "Sel¥"
	await AnimTimer.start_get(.05)
	label.text = "Sell 1¥"
	

func animate_out():
	visible = false
