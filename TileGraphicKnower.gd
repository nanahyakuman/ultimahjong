extends Node

var tiles_by_id = {
	
}

func log_tile(tile: MTile):
	var tid = tile.get_id()
	
	if !tiles_by_id.has(tid):
		tiles_by_id = [tile]
	else:
		tiles_by_id[tid].append(tile)

func unlog_tile(tile: MTile):
	var tid = tile.get_id()
	if tiles_by_id.has(tid):
		tiles_by_id[tid].erase(tile)
