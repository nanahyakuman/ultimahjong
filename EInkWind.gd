extends CursorTextRequester

@onready var sprite = $Sprite2D


func _ready():
	TileGraphicKnower.change_texture.connect(change_westernized)
	change_westernized()

# a little e-ink anim to highlight wind changes
func set_wind(wind: int):
	if wind == sprite.frame_coords.y:
		return
	for i in [4,6,5,6,4,6,5,wind]:
		sprite.frame_coords.y = i
		await AnimTimer.start_get(.08)
	

func change_westernized():
	sprite.frame_coords.x = TileGraphicKnower.wind_version
