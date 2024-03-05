##  graphically displays items, and also keeps track of item pooling
extends GridContainer

@onready var upgrades: Upgrades
@onready var tile_counter = $"../../../../../../../MahjongRoot/MahjongManager/TileCounter"
@onready var score_tracker = %ScoreTracker
@onready var upgrade = preload("res://upgrade.tscn")

var pool: ExpandingCounterDict = ExpandingCounterDict.new()


func initialize(ci: CharacterInfo, load: bool):
	pool = ExpandingCounterDict.new()
	for i in Upgrade.TYPES.size():
		if i == Upgrade.TYPES.UPR_NONE:
			continue
		var count = Upgrade.METADATA[i][Upgrade.METADATA_COUNT]
		pool.add(i, count)
	
	if !load:
		for i in ci.starting_uprgrades:
			gen_upgrade(i, false)


# return an array of randomly selected items left in pool
func get_random_from_pool(amount: int) -> Array:
	var legal = pool.get_count_greater_than(0)
	legal.shuffle()
	legal.resize(amount)
	
	return legal

# reduce the item count by 1
func alert_bought(type: int):
	pool.add(type, -1)

func gen_upgrade(type: int, load_mute: bool):
	var a = upgrade.instantiate()
	a.type = type
	add_child(a)
	if !upgrades:
		upgrades = $"../../../../../../../MahjongRoot/MahjongManager/Upgrades"
	# retrigger upgrades
	alert_bought(type)
	a.bought(upgrades, tile_counter, score_tracker, load_mute)


func load_cfg(config: ConfigFile):
	# let everything else set itself up first
	await get_tree().process_frame
	
	for i in Upgrade.TYPES.size():
		var count = config.get_value("upgrade", str(i), 0)
		for j in count:
			gen_upgrade(i, true)

func save_cfg(config: ConfigFile):
	var a = ExpandingCounterDict.new()
	for c in get_children():
		a.add(c.type)
	for u in Upgrade.TYPES.size():
		config.set_value("upgrade", str(u), a.at(u))
