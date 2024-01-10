##  nodes in group `save_options` should
## define `save_cfg()` and `load_cfg()`.
##  load is called at the beinning and save is called when you
## quit the game
extends Node

const SAVE_PATH = "user://settings.cfg"

var config

func _ready():
	queue_initialize()

# docs imply you shouldnt await in `_ready`
func queue_initialize():
	await get_tree().process_frame
	initialize()

func initialize():
	config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return
	
	load_cfg()

func load_cfg():
	get_tree().call_group("save_options", "load_cfg", config)
func save_cfg():
	get_tree().call_group("save_options", "save_cfg", config)
	config.save(SAVE_PATH)
