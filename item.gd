extends CursorTextRequester

@onready var counter_label = $PanelContainer/CounterLabel
@onready var sprite_2d = $Sprite2D
@onready var panel_container = $PanelContainer
var mahjong_manager

enum TYPES {NONE, ERASER}
@export var type = TYPES.NONE
var cooldown_counter

func _ready():
	cooldown_counter = 0
	sprite_2d.frame_coords.x = type
	
	# hovertexting
	match type:
		TYPES.ERASER:
			hover_text = "Current tsumo tile becomes a White Dragon (temporarily)."
	
	mahjong_manager = %MahjongManager
	
	decrement()
	super._ready()

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
			mahjong_manager.do_tsumo(MTile.new(MTile.SUITS.SPECIAL,MTile.SPECIALS.HAKU))
			cooldown_counter = 30
			
	
	assert(cooldown_counter > 0, "you forgot to reassign the cooldown counter!!")
	cooldown_counter += 1
	decrement()


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_use()
