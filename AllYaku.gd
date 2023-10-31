extends Node

var YAKUS = {
	"Tan'yao": ScoringInfo.Han.new("Tan'yao", 1, "No terminals or honors in hand."),
	"Yakuhai": ScoringInfo.Han.new("Yakuhai", 1, "Set or quad of seat wind, prevalent wind, or any dragon."),
	"Menzentsumo": ScoringInfo.Han.new("Menzentsumo", 1, "Closed hand, win by tsumo."),
	"Hon'itsu": ScoringInfo.Han.new("Hon'itsu", 3, "Hand only contains honors and tiles of a single suit."),
	"Open Hon'itsu": ScoringInfo.Han.new("Open Hon'itsu", 2, "Hand only contains honors and tiles of a single suit."),
	"Chin'itsu": ScoringInfo.Han.new("Chin'itsu", 6, "Hand only contains tiles of a single suit."),
	"Open Chin'itsu": ScoringInfo.Han.new("Open Chin'itsu", 5, "Hand only contains tiles of a single suit."),

#	"Kan Dora": ScoringInfo.Han.new("Kan Dora", 1, ""),
#	"Ura Dora": ScoringInfo.Han.new("Ura Dora", 1, ""),
#	"Aka Dora": ScoringInfo.Han.new("Aka Dora", 1, ""),
}

#  spacers are just so the ui can generate titles, shouldn't be accessed
# otherwise. probably a little dubious but i cant recall any fu named 
# "SPACER_1".
var FU = {
	"SPACER_1": "[b]Special[/b]",
	
	"Base": ScoringInfo.Fu.new("Base", 20),
	"Menzenkafu": ScoringInfo.Fu.new("Menzenkafu", 10),
	"Tsumo": ScoringInfo.Fu.new("Tsumo", 2),
	"Chiitoitsu": ScoringInfo.Fu.new("Chiitoitsu", 25),
	
	"SPACER_2": "[b]Groupings[/b]",
	
	"Run": ScoringInfo.Fu.new("Run", 0),
	## yakuhai runs dont exist
	"Pair": ScoringInfo.Fu.new("Pair", 0),
	#"Yakuhai Pair": ScoringInfo.Fu.new("Yakuhai Pair", 2),
	"Open Set": ScoringInfo.Fu.new("Open Set", 2),
	#"Yakuhai Open Set": ScoringInfo.Fu.new("Yakuhai Open Set", 4),
	"Closed Set": ScoringInfo.Fu.new("Closed Set", 4),
	#"Yakuhai Closed Set": ScoringInfo.Fu.new("Yakuhai Closed Set", 8),
	"Open Quad": ScoringInfo.Fu.new("Open Quad", 8),
	#"Yakuhai Open Quad": ScoringInfo.Fu.new("Yakuhai Open Quad", 16),
	"Closed Quad": ScoringInfo.Fu.new("Closed Quad", 16),
	#"Yakuhai Closed Quad": ScoringInfo.Fu.new("Yakuhai Closed Quad", 32),
	#  weird because it's not a fu of its own but this allows us to hijack
	# existing gui code.
	"Yakuhai Multiplier": ScoringInfo.Fu.new(" (Yakuhai)", 1.5),
	
	"SPACER_3": "[b]Waits",
	
	"1-sided Wait": ScoringInfo.Fu.new("1-sided Wait", 2),
	"2-sided Wait": ScoringInfo.Fu.new("2-sided Wait", 0),
	">=3-sided Wait": ScoringInfo.Fu.new(">=3-sided Wait", 0),
	
	"SPACER_4": "[b]Dora",
	
	"Kan Dora": ScoringInfo.Fu.new("Kan Dora", 8),
	"Ura Dora": ScoringInfo.Fu.new("Ura Dora", 8),
	"Aka Dora": ScoringInfo.Fu.new("Aka Dora", 8),
}

func _ready():
	upgrade_fu("Closed Quad")
	upgrade_fu("Closed Quad")
	upgrade_fu("Closed Quad")

func upgrade_fu(str: String):
	FU[str].fu += get_fu_upgrade(str)
	FU[str].times_upgraded += 1

func get_fu_upgrade(str: String):
	assert(FU.has(str), "fu \"%s\"does not exist!" % str)
	assert(FU[str] is ScoringInfo.Fu, "fu \"%s\"does not exist!" % str)
	
	if str == "Yakuhai Multiplier":
		return .5
	elif str == "Base":
		return 10
	else:
		return 2 if FU[str].fu == 0 else FU[str].fu
