extends Timer

var anim_speed_mod = 2.0
var skip = true

func start_get(time: float):
	if skip:
		return
	
	# we generate a new timer if tthis one is already runnung
	if !is_stopped():
		start(time)
		await timeout
		return
	else:
		await get_tree().create_timer(time).timeout
		return

func start_mod(time: float):
	var ret = await start_get(time / anim_speed_mod)
	return ret
