extends Control

@onready var counter_label = $PanelContainer/CounterLabel
@onready var sprite_2d = $Sprite2D
@onready var panel_container = $PanelContainer
@onready var description = $Description
@onready var hover_name = $Description/VBoxContainer/PanelContainer/HBoxContainer/PanelContainer/Name
@onready var hover_text = $Description/VBoxContainer/Label
var mahjong_manager

enum TYPES {NONE, ERASER}
@export var type = TYPES.NONE
var cooldown_counter

func _ready():
	connect("mouse_entered", _mouse_entered)
	connect("mouse_exited", _mouse_exited)
	_mouse_exited()
	
	# hovertexting
	match type:
		TYPES.ERASER:
			hover_name.text = "Eraser"
			hover_text.text = "Current tsumo tile becomes a White Dragon (temporarily)."
	
	cooldown_counter = 0
	sprite_2d.frame_coords.x = type
	
	mahjong_manager = %MahjongManager
	
	decrement()

func decrement():
	cooldown_counter -= 1
	panel_container.visible = cooldown_counter > 0
	counter_label.text = str(maxi(0,cooldown_counter))
	sprite_2d.frame_coords.y = 0 if cooldown_counter <= 0 else 1

func _use():
	if cooldown_counter >= 0:
		return
	if mahjong_manager:
		if mahjong_manager._state != MahjongManager.STATE_ACTIONABLE:
			return
	
	match type:
		TYPES.NONE:
			#actual code here
			cooldown_counter = 9999
		TYPES.ERASER:
			if mahjong_manager.tsumo:
				mahjong_manager.do_tsumo(MTile.new(MTile.SUITS.SPECIAL,MTile.SPECIALS.HAKU))
			cooldown_counter = 48
			
	
	assert(cooldown_counter > 0, "you forgot to reassign the cooldown counter!!")
	cooldown_counter += 1
	decrement()


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_use()

func _mouse_entered():
	description.visible = true
func _mouse_exited():
	description.visible = false
