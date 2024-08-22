##  contains canon information about all the yaku and fu awarded.
## changing values here will change how yaku are awarded, so you can buff/nerf
## yaku during a run.
extends Node

#  holds yaku that are multiple-referenced so that they can appear multiple times in
# the sidebar. msot of these are yaku that are also obviously themed
var duplicated = {
	"Chinroutou": ScoringInfo.Han.new("YAKU_CHINROUTOU", 13, 0, "🀙🀙🀙🀇🀇🀏🀏 🀏 🀡🀡🀡🀘🀘🀘"),
	"Daisangen": ScoringInfo.Han.new("YAKU_DAISANGEN", 13, 0, "🀪🀪🀪🀪🀪🀄🀄 🀄 🀅🀅🀅🀅🀆🀆🀆"),
}

#  the yaku sidebar reads from this directly, so some additional highlighting like
# spacers and duplicate support are added. it's not a terribly hinged move, but
# string values imply tabs, han values imply new yaku displays, and arrays imply 
# text to be added inbetween han.
#  keys are written out in plaintext because im too lazy to switch to a giant enum,
# but names and decriptions are automatically translated by the `Han` constructor.
#  the tilestrings are NOT translated!
var YAKUS = {
	"TAB_YAKU_SPECIAL": "TAB_YAKU_SPECIAL",
	"Riichi": ScoringInfo.Han.new("YAKU_RIICHI", 1, 1, "", true),
	"Double Riichi": ScoringInfo.Han.new("YAKU_DOUBLE_RIICHI", 2, 2),
	"Ippatsu": ScoringInfo.Han.new("YAKU_IPPATSU", 1, 1),
	
#	"SPACER_6": "Luck",
	"Haitei": ScoringInfo.Han.new("YAKU_HAITEI", 1, 0),
	"Rinshan": ScoringInfo.Han.new("YAKU_RINSHAN", 1, 0, "🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪 🀪←🀫🀪🀪🀫"),
	"Menzentsumo": ScoringInfo.Han.new("YAKU_MENZENTSUMO", 1, 1),
	
#	"SPACER_7": "Special",
	"Chiitoitsu": ScoringInfo.Han.new("YAKU_CHIITOITSU", 2, 0, "🀚🀚🀛🀛🀔🀔🀖🀖🀍🀍🀂🀂🀅🀅"),
	"Nagashi Mangan": ScoringInfo.Han.new("YAKU_NAGASHI", 4, 0, "🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪  "), #4 bc 5 = 10,000 rn
	
#	"SPACER_2": "Runs",
	"TAB_YAKU_GROUPS": "TAB_YAKU_GROUPS",
	"Pinfu": ScoringInfo.Han.new("YAKU_PINFU", 1, 1, "🀋🀌🀍🀑🀒🀓🀔🀕🀛🀜🀝🀡🀡 🀖"),
	"Iipeikou": ScoringInfo.Han.new("YAKU_IIPEIKOU", 1, 1, "🀇🀇🀈🀈🀉🀉"),
	"Ryanpeikou": ScoringInfo.Han.new("YAKU_RYANPEIKOU", 3, 1, "🀪🀪🀔🀕🀖🀇🀇🀈🀉🀉 🀈 🀔🀕🀖"),
	"Sanshoku Doujun": ScoringInfo.Han.new("YAKU_SANSHOKU_DOUJUN", 2, 1, "🀈🀉🀊🀑🀒🀓🀚🀛🀜"),
	"Ittsuu": ScoringInfo.Han.new("YAKU_ITTSUU", 2, 1, "🀐🀑🀒🀖🀗🀘🀪🀪🀪🀪 🀪 🀓🀔🀕"),
	
#	"SPACER_3": "Sets",
	"Toitoi": ScoringInfo.Han.new("YAKU_TOITOI", 2, 0, "🀃🀃🀅🀅 🀅 🀛🀛🀛🀞🀞🀞🀏🀏🀏"),
	"San'ankou": ScoringInfo.Han.new("YAKU_SANANKOU", 2, 0, "🀝🀝🀝🀕🀕🀕🀇🀇🀇🀋 🀋 🀪🀪🀪"),
	"Sankantsu": ScoringInfo.Han.new("YAKU_SANKANTSU", 2, 0, "🀪🀪🀪🀪 🀪 🀫🀌🀌🀫🀒🀒🀒🀒🀫🀀🀀🀫"),
	"Sanshoku Doukou": ScoringInfo.Han.new("YAKU_SANSHOKU_DOUKOU", 2, 0, "🀪🀪🀪🀪🀪🀔🀔 🀔 🀝🀝🀝🀋🀋🀋"),
	
	"TAB_YAKU_TILES": "TAB_YAKU_TILES",
	"Tan'yao": ScoringInfo.Han.new("YAKU_TANYAO", 1, 0, "🀞🀟🀠🀓🀓🀈🀉🀊🀎🀎 🀎 🀔🀕🀖", true),
	"Yakuhai": ScoringInfo.Han.new("YAKU_YAKUHAI", 1, 0, "🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪 🀪 🀄🀄🀄", true),
	"Shousangen": ScoringInfo.Han.new("YAKU_SHOUSANGEN", 2, 0, "🀪🀪🀪🀪🀪🀄🀄 🀪 🀅🀅🀅🀆🀆🀆"),
	#"Daisangen 2": duplicated["Daisangen"],
	"Chanta": ScoringInfo.Han.new("YAKU_CHANTA", 2, 1, "🀙🀚🀛🀇🀇🀇🀆 🀆 🀂🀂🀂🀟🀠🀡"),
	"Junchan": ScoringInfo.Han.new("YAKU_JUNCHAN", 3, 1, "🀇🀉🀐🀑🀒 🀈 🀙🀙🀙🀖🀗🀘🀍🀎🀏"),
	"Honroutou": ScoringInfo.Han.new("YAKU_HONROUTOU", 2, 0, "🀇🀇🀏🀏 🀇 🀘🀘🀘🀂🀂🀂🀁🀁🀁"),
	#"Chinroutou 2": duplicated["Chinroutou"],
	
#	"SPACER_5": "Suits",
	"Hon'itsu": ScoringInfo.Han.new("YAKU_HONITSU", 3, 1, "🀐🀑🀒🀔🀕🀖🀗 🀗 🀁🀁🀁🀆🀆🀆", true),
	"Chin'itsu": ScoringInfo.Han.new("YAKU_CHINITSU", 6, 1, "🀙🀚🀛🀜🀝🀠🀠 🀛 🀞🀟🀠🀡🀡🀡"),
	
	"TAB_YAKU_YAKUMAN": "TAB_YAKU_YAKUMAN",
	"TEXT_X": [tr("YAKU_YAKUMAN_INTRO")],
	"Kazoe Yakuman": ScoringInfo.Han.new("YAKU_KAZOE", 13, 0, "🀙🀙🀄🀄 🀙 🀀🀀🀀🀀🀆🀆🀆🀆🀫🀅🀅🀫"),
	"Daisangen": duplicated["Daisangen"],
	"Shousuushii": ScoringInfo.Han.new("YAKU_SHOUSUUSHII", 13, 0, "🀪🀪🀀🀀🀀🀃🀃 🀪 🀁🀁🀁🀂🀂🀂"),
	"Daisuushii": ScoringInfo.Han.new("YAKU_DAISUUSHII", 26, 0, "🀪🀪🀀🀀 🀀 🀁🀁🀁🀂🀂🀂🀃🀃🀃"),
	"Suuankou": ScoringInfo.Han.new("YAKU_SUUANKOU", 13, 0, "🀜🀜🀜🀞🀞🀞🀎🀂🀂🀂 🀎 🀫🀈🀈🀫"), 
	"Suukantsu": ScoringInfo.Han.new("YAKU_SUUKANTSU", 13, 0, "🀪 🀪 🀂🀂🀂🀂🀚🀚🀚🀚🀫🀓🀓🀫🀏🀏🀏🀏"),
	"Kokushi Musou": ScoringInfo.Han.new("YAKU_KOKUSHI", 13, 0, "🀙🀡🀘🀇🀏🀀🀁🀂🀃🀆🀆🀅🀄 🀐"),
	"Tsuuiisou": ScoringInfo.Han.new("YAKU_TSUUIISOU", 13, 0, "🀄🀄🀅🀅 🀄 🀁🀁🀁🀃🀃🀃🀆🀆🀆"),
	"Chinroutou": duplicated["Chinroutou"],
	"Ryuuiisou": ScoringInfo.Han.new("YAKU_RYUUIISOU", 13, 0, "🀑🀒🀓🀕🀕🀗🀗 🀕 🀅🀅🀅🀑🀒🀓"),
	"Chuuren Poutou": ScoringInfo.Han.new("YAKU_CHUUREN", 13, 13, "🀇🀇🀇🀈🀉🀊🀋🀌🀍🀎🀏🀏🀏 🀉"),
	
	"Kihou": ScoringInfo.Han.new("YAKU_KIHOU", 13, 0),
	
	#"TAB_YAKU_SECRET": "TAB_YAKU_SECRET",
	#"TEXT_Y": [tr("YAKU_SECRET_INTRO")],
	
	#  read as a give up flag, so no yaku tab is created. maybe
	# move to special??
	"DORA": "Dora",
	
	# moved here bc it's a bonus, not a tile
	"Flower": ScoringInfo.Han.new("YAKU_FLOWER", 1, 0, "🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪 🀪 🀢"),
	"North": ScoringInfo.Han.new("YAKU_KITA", 1, 0, "🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪🀪 🀪 🀃"),
	"Kan Dora": ScoringInfo.Han.new("YAKU_KAN_DORA", 1, 0, "", true),
	"Ura Dora": ScoringInfo.Han.new("YAKU_URA_DORA", 1, 0, ""),
	"Aka Dora": ScoringInfo.Han.new("YAKU_AKA_DORA", 1, 0, "", true),
	"Kin Dora": ScoringInfo.Han.new("YAKU_KIN_DORA", 2, 0, "",),
	"Murasaki Dora": ScoringInfo.Han.new("YAKU_MURASAKI_DORA", 1, 1, "",),
	"Kuro Dora": ScoringInfo.Han.new("YAKU_KURO_DORA", -1, 0, "",),
	
}

#  spacers are just so the ui can generate titles, shouldn't be accessed
# otherwise. probably a little dubious but i don't recall any fu named 
# "SPACER_1".
#  as with yaku, keys are just accesses, values are translation keys
var FU = {
	"SPACER_1": "FU_HEADER_SPECIAL",
	
	"Base": ScoringInfo.Fu.new("FU_TYPE_BASE", 20),
	"Menzenkafu": ScoringInfo.Fu.new("FU_TYPE_MENZENKAFU", 10),
	"Tsumo": ScoringInfo.Fu.new("FU_TYPE_TSUMO", 2),
	"Chiitoitsu": ScoringInfo.Fu.new("FU_TYPE_CHIITOITSU", 25),
#	"Ao Dora": ScoringInfo.Fu.new("FU_TYPE_AO_DORA", 10),
#	"Midori Dora": ScoringInfo.Fu.new("FU_TYPE_MIDORI_DORA", 10),
	
	"SPACER_2": "FU_HEADER_GROUPINGS",
	
	"Pair": ScoringInfo.Fu.new("FU_TYPE_PAIR", 0),
	"Yakuhai Pair": ScoringInfo.Fu.new("FU_TYPE_YAKUHAI_PAIR", 2),
	"Open Run": ScoringInfo.Fu.new("FU_TYPE_OPEN_RUN", 0),
	"Closed Run": ScoringInfo.Fu.new("FU_TYPE_CLOSED_RUN", 0),
	"Open Set": ScoringInfo.Fu.new("FU_TYPE_OPEN_SET", 2),
	"Closed Set": ScoringInfo.Fu.new("FU_TYPE_CLOSED_SET", 4),
	"Open Quad": ScoringInfo.Fu.new("FU_TYPE_OPEN_QUAD", 8),
	"Closed Quad": ScoringInfo.Fu.new("FU_TYPE_CLOSED_QUAD", 16),
	#  weird because it's not a fu of its own but this allows us to hijack
	# existing gui code.
	"Yaochuu Multiplier": ScoringInfo.Fu.new("FU_TYPE_YAOCHUU_MULT", 2),
	
	"SPACER_3": "FU_HEADER_WAITS",
	
	"1-sided Wait": ScoringInfo.Fu.new("FU_TYPE_1SIDED", 2),
	"2-sided Wait": ScoringInfo.Fu.new("FU_TYPE_2SIDED", 0),
	">=3-sided Wait": ScoringInfo.Fu.new("FU_TYPE_3SIDED", 0),
	
#	"SPACER_4": "[b]Dora",
#
}

var CHIPS = {
	"Ao Dora": ScoringInfo.Chip.new("CHIP_TYPE_AO_DORA"),
	"Midori Dora": ScoringInfo.Chip.new("CHIP_TYPE_MIDORI_DORA"),
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
#func format_han():
#	for h in YAKUS.values():
#		if !(h is ScoringInfo.Han):
#			continue
#		for hn in YAKUS.values():
#			if !(hn is ScoringInfo.Han):
#				continue
#			h.desc = h.desc.replace(hn.nam, "[color=%s]%s[/color]" % [COL.YELLOW, hn.nam])
