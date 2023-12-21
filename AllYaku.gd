##  contains canon information about all the yaku and fu awarded.
## changing values here will change how yaku are awarded, so you can buff/nerf
## yaku during a run.
extends Node

#  holds yaku that are multiple-referenced so that they can appear multiple times in
# the sidebar. msot of these are yaku that are also obviously themed
var duplicated = {
	"Chinroutou": ScoringInfo.Han.new("Chinrōtō", 13, 0, "Hand only contains terminals (no honors).", "🀙🀙🀙🀇🀇🀏🀏 🀏 🀡🀡🀡🀘🀘🀘"),
	"Daisangen": ScoringInfo.Han.new("Daisangen", 13, 0, "Three Dragon sets/quads.", "🀪🀪🀪🀪🀪🀄🀄 🀄 🀅🀅🀅🀅🀆🀆🀆"),
}

#  the yaku sidebar reads from this directly, so some additional highlighting like
# spacers and duplicate support are added. it's not a terribly hinged move, but
# string values imply tabs, han values imply new yaku displays, and arrays imply 
# text to be added inbetween han.
#  keys are written out in plaintext, but names and decriptions may feature macrons or
# bbcode.
var YAKUS = {
	"SPACER_1": "Special",
	"Riichi": ScoringInfo.Han.new("Rīchi", 1, 1, "Once you're one tile away from a completed hand, you can enter Rīchi. This prevents you from modifying your hand any further; all you can do is wait until your winning tile is discarded, or you draw it yourself.\nCosts 1000 points to enter, but these are returned if successful.\nEnables Ippatsu."),
	"Double Riichi": ScoringInfo.Han.new("Double Rīchi", 2, 2, "Declare Rīchi with your first discard."),
	"Ippatsu": ScoringInfo.Han.new("Ippatsu", 1, 1, "Win before or on your first draw after declaring Rīchi."),
	
#	"SPACER_6": "Luck",
	"Haitei": ScoringInfo.Han.new("Haitei", 1, 0, "Win off the last drawn tile in the wall."),
	"Rinshan": ScoringInfo.Han.new("Rinshan", 1, 0, "Win off the tile redraw when calling a kan.", "🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪 🀪←🀫🀪🀪🀫"),
	"Menzentsumo": ScoringInfo.Han.new("Menzentsumo", 1, 1, "Win by tsumo with a closed hand."),
	
#	"SPACER_7": "Special",
	"Chiitoitsu": ScoringInfo.Han.new("Chītoitsu", 2, 0, "Hand contains seven pairs. Four of the same tile OK [i]as long as[/i] kan is not called.", "🀚🀚🀛🀛🀔🀔🀖🀖🀍🀍🀂🀂🀅🀅"),
	"Nagashi Mangan": ScoringInfo.Han.new("Nagashi Mangan", 5, 0, "A round ends with no other win, and your [i]discards[/i] consist solely of terminals and honors.", "🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪  "),
	
#	"SPACER_2": "Runs",
	"SPACER_2": "Groups",
	"Pinfu": ScoringInfo.Han.new("Pinfu", 1, 1, "No fu except futei and dora fu. This works out to mean: All runs, non-yakuhai pair, and a ryanmen wait.", "🀋🀌🀍🀑🀒🀓🀔🀕🀛🀜🀝🀡🀡 🀖"),
	"Iipeikou": ScoringInfo.Han.new("Īpeikō", 1, 1, "Two copies of the same run.", "🀇🀇🀈🀈🀉🀉"),
	"Ryanpeikou": ScoringInfo.Han.new("Ryanpeikō", 3, 1, "Two copies of Īpeikō. The two Īpeikō [i]may[/i] be of different suits, or they [i]may[/i] contain duplicate tiles. [i]Incompatible[/i] with Chītoitsu.", "🀪🀪🀔🀕🀖🀇🀇🀈🀉🀉 🀈 🀔🀕🀖"),
	"Sanshoku Doujun": ScoringInfo.Han.new("Sanshoku Dōjun", 2, 1, "The same value run in three numbered suits.", "🀈🀉🀊🀑🀒🀓🀚🀛🀜"),
	"Ittsuu": ScoringInfo.Han.new("Ittsū", 2, 1, "A \"Full Straight\", 1-9 in a single suit. [i]Specifically demands[/i] a winning hand containing the runs 123, 456, and 789, [i]not[/i] just having at least one of every tile.", "🀐🀑🀒🀖🀗🀘🀪🀪🀪🀪 🀪 🀓🀔🀕"),
	
#	"SPACER_3": "Sets",
	"Toitoi": ScoringInfo.Han.new("Toitoi", 2, 0, "Hand consists of four set/quads and a pair.", "🀃🀃🀅🀅 🀅 🀛🀛🀛🀞🀞🀞🀏🀏🀏"),
	"San'ankou": ScoringInfo.Han.new("San'ankō", 2, 0, "Three concealed sets (quads OK). The [i]sets themselves[/i] must be entirely concealed; finishing the last set with ron does [i]not[/i] qualify.", "🀝🀝🀝🀕🀕🀕🀇🀇🀇🀋 🀋 🀪🀪🀪"),
	"Sankantsu": ScoringInfo.Han.new("Sankantsu", 2, 0, "Call kan three times.", "🀪🀪🀪🀪 🀪 🀫🀌🀌🀫🀫🀒🀒🀫🀫🀀🀀🀫"),
	"Sanshoku Doukou": ScoringInfo.Han.new("Sanshoku Dōkō", 2, 0, "The same value set in three numbered suits.", "🀪🀪🀪🀪🀪🀔🀔 🀔 🀝🀝🀝🀋🀋🀋"),
	
	"SPACER_4": "Tiles",
	"Flower": ScoringInfo.Han.new("Flower", 1, 0, "Called flower tile.", "🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪 🀪 🀢"),
	"Tan'yao": ScoringInfo.Han.new("Tan'yao", 1, 0, "No terminals or honors in hand.", "🀞🀟🀠🀓🀓🀈🀉🀊🀎🀎 🀎 🀔🀕🀖"),
	"Yakuhai": ScoringInfo.Han.new("Yakuhai", 1, 0, "Set or quad of seat wind, prevalent wind, or any dragon. Stacks with self if multiple qualifying sets are present.", "🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪 🀪 🀄🀄🀄"),
	"Shousangen": ScoringInfo.Han.new("Shōsangen", 2, 0, "Two Dragon sets/quads and a Dragon pair. Adds onto the existing two Yakuhai, for four total han awarded on the dragons.", "🀪🀪🀪🀪🀪🀄🀄 🀪 🀅🀅🀅🀆🀆🀆"),
	#"Daisangen 2": duplicated["Daisangen"],
	"Chanta": ScoringInfo.Han.new("Chanta", 2, 1, "Every grouping/pair contains an honor or terminal.", "🀙🀚🀛🀇🀇🀇🀆 🀆 🀂🀂🀂🀟🀠🀡"),
	"Junchan": ScoringInfo.Han.new("Junchan", 3, 1, "Every grouping/pair contains a terminal. Disables Chanta.", "🀇🀉🀐🀑🀒 🀈 🀙🀙🀙🀖🀗🀘🀍🀎🀏"),
	"Honroutou": ScoringInfo.Han.new("Honrōtō", 2, 0, "Every grouping is a set of terminals or honors. Additonally implies either Toitoi or Chītoitsu. Disables Junchan and Chanta.", "🀇🀇🀏🀏 🀇 🀘🀘🀘🀂🀂🀂🀁🀁🀁"),
	#"Chinroutou 2": duplicated["Chinroutou"],
	
#	"SPACER_5": "Suits",
	"Hon'itsu": ScoringInfo.Han.new("Hon'itsu", 3, 1, "Hand only contains honors and tiles of a single suit.", "🀐🀑🀒🀔🀕🀖🀗 🀗 🀁🀁🀁🀆🀆🀆"),
	"Chin'itsu": ScoringInfo.Han.new("Chin'itsu", 6, 1, "Hand only contains tiles of a single suit.", "🀙🀚🀛🀜🀝🀠🀠 🀛 🀞🀟🀠🀡🀡🀡"),
	
	"SPACER_X": "Yakuman",
#	"TEXT_X": ["Unlike other yaku, Yakuman generally disable any han they imply. For example: Suukantsu disables Sankantsu, Daisangen disables Shousangen and those dragon's Yakuhai."],
	"TEXT_X": ["Note that Yakuman are automatic limit hands, after which han are simply defined as {number of Yakuman × 13}. It [i]is[/i] possible to meet multiple Yakuman requirements simultaneously; you will be rewarded for all of them."],
	"Kazoe Yakuman": ScoringInfo.Han.new("Kazoe Yakuman", 13, 0, "Never awarded itself, simply a name for any hand that reaches or exceeds thirteen han without fulfilling any defined Yakuman pattern. Any other Yakuman disables this one, so there can be no multiple Yakuman hands containing Kazoe.", "🀙🀙🀄🀄 🀙 🀀🀀🀀🀀🀆🀆🀆🀆🀫🀅🀅🀫"),
	"Daisangen": duplicated["Daisangen"],
	"Shousuushii": ScoringInfo.Han.new("Shōsūshī", 13, 0, "Three sets/quads of winds and a pair of the fourth.", "🀪🀪 🀀🀀🀀🀃🀃 🀪 🀁🀁🀁🀂🀂🀂"),
	"Daisuushii": ScoringInfo.Han.new("Daisūshī", 26, 0, "Four sets/quads of winds.", "🀪🀪🀀🀀 🀀 🀁🀁🀁🀂🀂🀂🀃🀃🀃"),
	"Suuankou": ScoringInfo.Han.new("Sūankō", 13, 0, "Four concealed sets (quads OK). The [i]sets themselves[/i] must be entirely concealed; finishing the last set with ron does [i]not[/i] qualify.", "🀜🀜🀜🀞🀞🀞🀈🀈🀈🀎🀂🀂🀂 🀎"), 
	"Suukantsu": ScoringInfo.Han.new("Sūkantsu", 13, 0, "Four quads.", "🀪 🀪 🀂🀂🀂🀂🀚🀚🀚🀚🀫🀓🀓🀫🀏🀏🀏🀏"),
	"Kokushi Musou": ScoringInfo.Han.new("Kokushi Musō", 13, 0, "One of every terminal and honor, and a second of any of them.", "🀙🀡🀘🀇🀏🀀🀁🀂🀃🀆🀆🀅🀄 🀐"),
	"Tsuuiisou": ScoringInfo.Han.new("Tsūīsō", 13, 0, "Hand only contains honors.", "🀄🀄🀅🀅 🀄 🀁🀁🀁🀃🀃🀃🀆🀆🀆"),
	"Chinroutou": duplicated["Chinroutou"],
	"Ryuuiisou": ScoringInfo.Han.new("Ryūīsō", 13, 0, "Hand only contains 2/3/4/6/8-Sou and Green Dragons. These are traditionally the tiles with only green ink on them, however, recolored variants of these tiles still contribute.", "🀑🀒🀓🀕🀕🀗🀗 🀕 🀅🀅🀅🀑🀒🀓"),
	"Chuuren Poutou": ScoringInfo.Han.new("Chūren Pōtō", 13, 13, "1112345678999 of any suit, plus one more tile from the suit.", "🀇🀇🀇🀈🀉🀊🀋🀌🀍🀎🀏🀏🀏 🀉"),
	
	"Kihou": ScoringInfo.Han.new("Kihō", 13, 0, "Complete a hand without ever discarding."),
	
	#  read as a give up flag, so no yaku tab is created. maybe
	# move to special??
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
	
	"Base": ScoringInfo.Fu.new("Base", 0),#20),
	"Menzenkafu": ScoringInfo.Fu.new("Menzenkafu", 8),#10),
	"Tsumo": ScoringInfo.Fu.new("Tsumo", 2),
	"Chiitoitsu": ScoringInfo.Fu.new("Chītoitsu", 5),#25),
	"Ao Dora": ScoringInfo.Fu.new("Ao Dora", 16),
	
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
	"Yaochuu Multiplier": ScoringInfo.Fu.new("(Yaochū)", 2),
	
	"SPACER_3": "[b]Waits",
	
	"1-sided Wait": ScoringInfo.Fu.new("1-sided Wait", 2),
	"2-sided Wait": ScoringInfo.Fu.new("2-sided Wait", 0),
	">=3-sided Wait": ScoringInfo.Fu.new(">=3-sided Wait", 0),
	
#	"SPACER_4": "[b]Dora",
#
}

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

# syntax highlight yaku
func format_han():
	for h in YAKUS.values():
		if !(h is ScoringInfo.Han):
			continue
		for hn in YAKUS.values():
			if !(hn is ScoringInfo.Han):
				continue
			h.desc = h.desc.replace(hn.nam, "[color=%s]%s[/color]" % [COL.YELLOW, hn.nam])
