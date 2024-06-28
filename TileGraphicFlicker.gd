extends Sprite2D

func _process(_delta: float):
	frame = (frame+1) % hframes
