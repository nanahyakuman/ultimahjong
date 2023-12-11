extends Timer

var anim_speed_mod = 2.0
var skip = true

func start_get(time: float):
	if skip:
		return
	start(time)
	await timeout
	return

func start_mod(time: float):
	var ret = await start_get(time / anim_speed_mod)
	return ret
