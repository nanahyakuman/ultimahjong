extends PanelContainer

@onready var gui_manager = $".."

var tile_select_requestor_node

func _ready():
	visible = false

# make use of existing guimanager code
func set_tiles(tiles: Array):
	gui_manager.update_tile_select(tiles)
	visible = tiles.size() != 0

func request_tile_select(requestor: Node):
	tile_select_requestor_node = requestor

func tile_graphic_clicked(tile: MTile):
	tile_select_requestor_node.tile_selected(tile)
