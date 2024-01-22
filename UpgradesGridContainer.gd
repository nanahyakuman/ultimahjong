extends GridContainer

@onready var upgrades
@onready var upgrade = preload("res://upgrade.tscn")

func load_cfg(config: ConfigFile):
	for i in Upgrade.TYPES.size():
		var count = config.get_value("item", str(i), 0)
		for j in count:
			var a = upgrade.instantiate()
			a.type = i
			add_child(a)
			if !upgrades:
				upgrades = $"../../../../../../../MahjongRoot/MahjongManager/Upgrades"
			a.bought(upgrades)

func save_cfg(config: ConfigFile):
	var a = ExpandingCounterDict.new()
	for c in get_children():
		a.add(c.type)
	for u in a.counts:
		config.set_value("item", str(u), a.counts[u])
