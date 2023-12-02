##  contains canon information about all the yaku and fu awarded.
## changing values here will change how yaku are awarded, so you can buff/nerf
## yaku during a run.
extends Node

var YAKUS = {
	"SPACER_1": "Special",
	"Riichi": ScoringInfo.Han.new("Riichi", 1, 1, "RIICHI_DESC!!"),
	"Double Riichi": ScoringInfo.Han.new("Double Riichi", 2, 2, "D_RIICHI_DESC!!"),
	"Ippatsu": ScoringInfo.Han.new("Ippatsu", 1, 1, "IIPS_DESC"),
	
#	"SPACER_6": "Luck",
	"Haitei": ScoringInfo.Han.new("Haitei", 1, 0, "Win off the last tile in the wall."),
	"Rinshan": ScoringInfo.Han.new("Rinshan", 1, 0, "Win off the tile redraw when calling a kan."),
	"Menzentsumo": ScoringInfo.Han.new("Menzentsumo", 1, 1, "Win by tsumo with a closed hand."),
	
#	"SPACER_7": "Special",
	"Chiitoitsu": ScoringInfo.Han.new("Chiitoitsu", 2, 0, "Hand contains seven pairs. 4 of the same tile OK as long as kan is not called."),
	"Nagashi": ScoringInfo.Han.new("Nagashi", 5, 0, "A round ends with no other win, and your discards consist solely of terminals and honors."),
	
#	"SPACER_2": "Runs",
	"SPACER_2": "Groups",
	"Pinfu": ScoringInfo.Han.new("Pinfu", 1, 1, "No fu except futei and dora fu."),
	"Iipeikou": ScoringInfo.Han.new("Iipeikou", 1, 0, "Two copies of the same run, i.e. 334455p."),
	"Ryanpeikou": ScoringInfo.Han.new("Ryanpeikou", 3, 1, "Two copies of Iipeikou, i.e. 223344p 334455s. The two Iipeikou may be of different suits, or they may contain duplicate tiles."),
	"Sanshoku Doujun": ScoringInfo.Han.new("Sanshoku Doujun", 2, 1, "The same value run in all three numbered suits."),
	"Ittsuu": ScoringInfo.Han.new("Ittsuu", 2, 1, "A \"Full Straight\", 1-9 in a single suit. Specifically demands a winning hand containing the runs 123, 456, and 789, NOT just having at least one of every tile."),
	
#	"SPACER_3": "Sets",
	"Toitoi": ScoringInfo.Han.new("Toitoi", 2, 0, "Hand consists of 4 set/quads and a pair."),
	"San'ankou": ScoringInfo.Han.new("San'ankou", 2, 0, "Three concealed sets (quads OK). The sets themselves must be entirely concealed, finishing the 3rd set with ron does not qualify."),
	"Sankantsu": ScoringInfo.Han.new("Sankantsu", 2, 0, "Call kan 3 times."),
	"Sanshoku Doukou": ScoringInfo.Han.new("Sanshoku Doukou", 2, 0, "The same value set in all three numbered suits."),
	
	"SPACER_4": "Tiles",
	"Tan'yao": ScoringInfo.Han.new("Tan'yao", 1, 0, "No terminals or honors in hand."),
	"Yakuhai": ScoringInfo.Han.new("Yakuhai", 1, 0, "Set or quad of seat wind, prevalent wind, or any dragon."),
	"Chanta": ScoringInfo.Han.new("Chanta", 2, 1, ""),
	"Junchan": ScoringInfo.Han.new("Junchan", 3, 2, ""),
	"Honroutou": ScoringInfo.Han.new("Honroutou", 2, 0, ""),
	"Shousangen": ScoringInfo.Han.new("Shousangen", 2, 0, "2 Dragon sets and a Dragon pair."),
	
#	"SPACER_5": "Suits",
	"Hon'itsu": ScoringInfo.Han.new("Hon'itsu", 3, 1, "Hand only contains honors and tiles of a single suit."),
	"Chin'itsu": ScoringInfo.Han.new("Chin'itsu", 6, 1, "Hand only contains tiles of a single suit."),
	
	"SPACER_X": "Yakuman",
	"Daisangen": ScoringInfo.Han.new("Daisangen", 13, 0, "3 Dragon sets."),
	"Tsuuiisou": ScoringInfo.Han.new("Tsuuiisou", 13, 0, ""),
	"Chinroutou": ScoringInfo.Han.new("Chinroutou", 13, 0, ""),
	
	# read as a give up flag
	"DORA": "Dora",
	
	"Kan Dora": ScoringInfo.Han.new("Kan Dora", 1, 0, ""),
	"Ura Dora": ScoringInfo.Han.new("Ura Dora", 1, 0, ""),
	"Aka Dora": ScoringInfo.Han.new("Aka Dora", 1, 0, ""),
}

#  spacers are just so the ui can generate titles, shouldn't be accessed
# otherwise. probably a little dubious but i don't recall any fu named 
# "SPACER_1".
var FU = {
	"SPACER_1": "[b]Special[/b]",
	
	"Base": ScoringInfo.Fu.new("Base", 20),
	"Menzenkafu": ScoringInfo.Fu.new("Menzenkafu", 10),
	"Tsumo": ScoringInfo.Fu.new("Tsumo", 2),
	"Chiitoitsu": ScoringInfo.Fu.new("Chiitoitsu", 25),
	
	"SPACER_2": "[b]Groupings[/b]",
	
	"Pair": ScoringInfo.Fu.new("Pair", 0),
	"Yakuhai Pair": ScoringInfo.Fu.new("Yakuhai Pair", 2),
	"Open Run": ScoringInfo.Fu.new("Open Run", 0),
	"Closed Run": ScoringInfo.Fu.new("Closed Run", 0),
	"Open Set": ScoringInfo.Fu.new("Open Set", 2),
	"Closed Set": ScoringInfo.Fu.new("Closed Set", 4),
	"Open Quad": ScoringInfo.Fu.new("Open Quad", 8),
	"Closed Quad": ScoringInfo.Fu.new("Closed Quad", 16),
	#  weird because it's not a fu of its own but this allows us to hijack
	# existing gui code.
	"Yaochuu Multiplier": ScoringInfo.Fu.new("(Yaochuu)", 2),
	
	"SPACER_3": "[b]Waits",
	
	"1-sided Wait": ScoringInfo.Fu.new("1-sided Wait", 2),
	"2-sided Wait": ScoringInfo.Fu.new("2-sided Wait", 0),
	">=3-sided Wait": ScoringInfo.Fu.new(">=3-sided Wait", 0),
	
#	"SPACER_4": "[b]Dora",
#
	"Ao Dora": ScoringInfo.Fu.new("Ao Dora", 16),
}

#func _ready():
#	upgrade_fu("Closed Quad")
#	upgrade_fu("Closed Quad")
#	upgrade_fu("Closed Quad")

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
