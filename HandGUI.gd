extends HBoxContainer

@onready var gui_manager = $"../../../../.."
@onready var tsumo = $"../Tsumo"

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

func do_hover_cursor(do: bool):
	for node in [self, tsumo]:
		for c in node.get_children():
			c.mouse_default_cursor_shape = CURSOR_POINTING_HAND if do else CURSOR_ARROW
	
