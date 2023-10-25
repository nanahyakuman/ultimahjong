extends Timer

var anim_speed_mod =1.0

func start_get(time: float) -> Timer:
	start(time)
	return self

func start_mod(time: float) -> Timer:
	start(time / anim_speed_mod)
	return self
