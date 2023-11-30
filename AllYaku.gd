extends Node

var YAKUS = {
	"SPACER_1": "Special",
	"Riichi": ScoringInfo.Han.new("Riichi", 1, "RIICHI_DESC!!"),
	"Double Riichi": ScoringInfo.Han.new("Double Riichi", 2, "D_RIICHI_DESC!!"),
	"Ippatsu": ScoringInfo.Han.new("Ippatsu", 1, "IIPS_DESC"),
	
#	"SPACER_6": "Luck",
	"Suitei": ScoringInfo.Han.new("Suitei", 1, "SUITEI_DESC"),
	"Rinshan": ScoringInfo.Han.new("Rinshan", 1, "RNSHN_DESC"),
	"Menzentsumo": ScoringInfo.Han.new("Menzentsumo", 1, "Closed hand, win by tsumo."),
	
#	"SPACER_7": "Special",
	"Chiitoitsu": ScoringInfo.Han.new("Chiitoitsu", 2, "7P_DESC"),
	"Nagashi": ScoringInfo.Han.new("Nagashi", 5, "ng"),
	
#	"SPACER_2": "Runs",
	"SPACER_2": "Groups",
	"Pinfu": ScoringInfo.Han.new("Pinfu", 1, "No fu."),
	"Iipeikou": ScoringInfo.Han.new("Iipeikou", 1, "ipk"),
	"Ryanpeikou": ScoringInfo.Han.new("Ryanpeikou", 3, "2pk"),
	"Sanshoku Doujun": ScoringInfo.Han.new("Sanshoku Doujun", 2, "ss"),
	"Open Sanshoku": ScoringInfo.Han.new("Open Sanshoku", 1, "os"), #note we drop 'doujun' here
	"Ittsuu": ScoringInfo.Han.new("Ittsuu", 2, "its"),
	"Open Ittsuu": ScoringInfo.Han.new("Open Ittsuu", 1, "its"),
	
#	"SPACER_3": "Sets",
	"Toitoi": ScoringInfo.Han.new("Toitoi", 2, "Hand consists of 4 set/quads and a pair."),
	"San'ankou": ScoringInfo.Han.new("San'ankou", 2, "sank"),
	"Sankantsu": ScoringInfo.Han.new("Sankantsu", 2, "3k"),
	"Sanshoku Doukou": ScoringInfo.Han.new("Sanshoku Doukou", 2, "3dk"),
	
	"SPACER_4": "Tiles",
	"Tan'yao": ScoringInfo.Han.new("Tan'yao", 1, "No terminals or honors in hand."),
	"Yakuhai": ScoringInfo.Han.new("Yakuhai", 1, "Set or quad of seat wind, prevalent wind, or any dragon."),
	"Chanta": ScoringInfo.Han.new("Chanta", 2, ""),
	"Open Chanta": ScoringInfo.Han.new("Open Chanta", 1, ""),
	"Junchan": ScoringInfo.Han.new("Junchan", 3, ""),
	"Open Junchan": ScoringInfo.Han.new("Open Junchan", 2, ""),
	"Honroutou": ScoringInfo.Han.new("Honroutou", 2, ""),
	"Shousangen": ScoringInfo.Han.new("Shousangen", 2, ""),
	
#	"SPACER_5": "Suits",
	"Hon'itsu": ScoringInfo.Han.new("Hon'itsu", 3, "Hand only contains honors and tiles of a single suit."),
	"Open Hon'itsu": ScoringInfo.Han.new("Open Hon'itsu", 2, "Hand only contains honors and tiles of a single suit."),
	"Chin'itsu": ScoringInfo.Han.new("Chin'itsu", 6, "Hand only contains tiles of a single suit."),
	"Open Chin'itsu": ScoringInfo.Han.new("Open Chin'itsu", 5, "Hand only contains tiles of a single suit."),
	
	"SPACER_X": "Yakuman",
	"Daisangen": ScoringInfo.Han.new("Shousangen", 13, ""),
	"Tsuuiisou": ScoringInfo.Han.new("Tsuuiisou", 13, ""),
	"Chinroutou": ScoringInfo.Han.new("Chinroutou", 13, ""),
	
	# read as a give up flag
	"DORA": "Dora",
	
	"Kan Dora": ScoringInfo.Han.new("Kan Dora", 1, ""),
	"Ura Dora": ScoringInfo.Han.new("Ura Dora", 1, ""),
	"Aka Dora": ScoringInfo.Han.new("Aka Dora", 1, ""),
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
