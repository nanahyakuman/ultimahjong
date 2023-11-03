extends Sprite2D

#var frame_f = 0
#var speed = 1
#
#func _process(delta: float):
#	frame_f = fmod(frame_f+speed, float(hframes))
#	frame = frame_f

func _process(delta: float):
	frame = (frame+1) % hframes
