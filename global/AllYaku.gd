extends Node

var YAKUS = {
	"Tan'yao": ScoringInfo.Han.new("Tan'yao", 1, "No terminals or honors in hand."),
	"Yakuhai": ScoringInfo.Han.new("Yakuhai", 1, "Set or quad of seat wind, prevalent wind, or any dragon."),
	"Menzentsumo": ScoringInfo.Han.new("Menzentsumo", 1, "Closed hand, win by tsumo."),
	"Hon'itsu": ScoringInfo.Han.new("Hon'itsu", 3, "Hand only contains honors and tiles of a single suit."),
	"Open Hon'itsu": ScoringInfo.Han.new("Open Hon'itsu", 2, "Hand only contains honors and tiles of a single suit."),
	"Chin'itsu": ScoringInfo.Han.new("Chin'itsu", 6, "Hand only contains tiles of a single suit."),
	"Open Chin'itsu": ScoringInfo.Han.new("Open Chin'itsu", 5, "Hand only contains tiles of a single suit."),
}
