extends Sprite2D

var SPEED = 3
var counter = 0.0

func _process(delta):
	counter += SPEED * delta
	counter = fmod(counter,vframes)
	
	frame_coords.y = int(counter)
