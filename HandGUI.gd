extends HBoxContainer

#  highlight tiles used in a chi/pon/kan
func highlight_relevant_tiles(tiles: Array, val: bool):
	if !val:
		for tg in get_children():
			tg.direct_request_highlight(false)
	else:
		var tids = []
		for t in tiles:
			tids.append(t.get_id())
		for tg in get_children():
			var tgid = tg.tile.get_id()
			if tids.has(tgid):
				tg.direct_request_highlight(true)
				tids.erase(tgid)
