extends CursorTextRequester

@onready var anim_timer = %AnimTimer
@onready var sprite = $Sprite2D

# a little e-ink anim to highlight wind changes
func set_wind(wind: int):
	if wind == sprite.frame:
		return
	for i in [4,5,4,5,wind]:
		sprite.frame = i
		await anim_timer.start_get(.2)
	
