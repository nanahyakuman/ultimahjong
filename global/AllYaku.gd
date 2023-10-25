extends Node

var YAKUS = {
	"Tan'yao": ScoringInfo.Han.new("Tan'yao", 1, "No terminals or honors in hand."),
	"Yakuhai": ScoringInfo.Han.new("Yakuhai", 1, "Set or quad of seat wind, prevalent wind, or any dragon."),
	"Menzentsumo": ScoringInfo.Han.new("Menzentsumo", 1, "Closed hand, win by tsumo."),
	"Hon'itsu": ScoringInfo.Han.new("Hon'itsu", 3, "Hand only contains honors and tiles of a single suit."),
	"Open Hon'itsu": ScoringInfo.Han.new("Open Hon'itsu", 2, "Hand only contains honors and tiles of a single suit."),
	"Chin'itsu": ScoringInfo.Han.new("Chin'itsu", 6, "Hand only contains tiles of a single suit."),
	"Open Chin'itsu": ScoringInfo.Han.new("Open Chin'itsu", 5, "Hand only contains tiles of a single suit."),

	"Kan Dora": ScoringInfo.Han.new("Kan Dora", 1, ""),
	"Ura Dora": ScoringInfo.Han.new("Ura Dora", 1, ""),
	"Aka Dora": ScoringInfo.Han.new("Aka Dora", 1, ""),
}

var FU = {
	"Base": ScoringInfo.Fu.new("Base", 20),
	"Menzenkafu": ScoringInfo.Fu.new("Menzenkafu", 10),
	"Tsumo": ScoringInfo.Fu.new("Tsumo", 2),
	"Chiitoitsu": ScoringInfo.Fu.new("Chiitoitsu", 25),
	
	"Run": ScoringInfo.Fu.new("Run", 0),
	## yakuhai runs dont exist
	"Pair": ScoringInfo.Fu.new("Pair", 0),
	"Yakuhai Pair": ScoringInfo.Fu.new("Yakuhai Pair", 2),
	"Open Set": ScoringInfo.Fu.new("Open Set", 2),
	"Yakuhai Open Set": ScoringInfo.Fu.new("Yakuhai Open Set", 4),
	"Closed Set": ScoringInfo.Fu.new("Closed Set", 4),
	"Yakuhai Closed Set": ScoringInfo.Fu.new("Yakuhai Closed Set", 8),
	"Open Quad": ScoringInfo.Fu.new("Open Quad", 8),
	"Yakuhai Open Quad": ScoringInfo.Fu.new("Yakuhai Open Quad", 16),
	"Closed Quad": ScoringInfo.Fu.new("Closed Quad", 16),
	"Yakuhai Closed Quad": ScoringInfo.Fu.new("Yakuhai Closed Quad", 32),
	
	"1-sided Wait": ScoringInfo.Fu.new("1-sided Wait", 2),
	"2-sided Wait": ScoringInfo.Fu.new("2-sided Wait", 0),
	">=3-sided Wait": ScoringInfo.Fu.new(">=3-sided Wait", 0),
}
