##  nodes in group `save_options` should
## define `save_cfg()` and `load_cfg()`.
##  load is called at the beinning and save is called when you
## quit the game
extends Node

@export var SAVE_PATH = "user://settings.cfg"
@export var associated_group = "save_options"
@export var autoload = true

var config

func _ready():
	if autoload:
		_queue_load()

# docs imply you shouldnt await in `_ready`
func _queue_load():
	await get_tree().process_frame
	load_cfg()

func initialize():
	config = ConfigFile.new()
	var _err = config.load(SAVE_PATH)

func load_cfg():
	if !config:
		initialize()
	get_tree().call_group(associated_group, "load_cfg", config)
func save_cfg():
	if !config:
		initialize()
	get_tree().call_group(associated_group, "save_cfg", config)
	config.save(SAVE_PATH)
# erase saves on loss
func clear_cfg():
	config =  null
	DirAccess.remove_absolute(SAVE_PATH)
