extends HBoxContainer

@onready var gui_manager = $"../../../../.."

#  highlight tiles used in a chi/pon/kan. called by individual calls
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
	
	if gui_manager.most_recent_discard:
		gui_manager.most_recent_discard.direct_request_highlight(val)
