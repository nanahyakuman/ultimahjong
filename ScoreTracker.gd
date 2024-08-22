extends Node

@onready var gui_manager = $"../HBoxContainer/MahjongRoot/GUIManager"
@onready var root = $".."

var score: float = 0
var expected_score: float = 0
var expected_points_mod: float = 0
var future_expected_score: float = 0

var max_score = 0
 
# kept so we can reference constants
var ci: CharacterInfo

func initialize(character_info: CharacterInfo, load: bool):
	ci = character_info
	if !load:
		score = character_info.base_score
		expected_score = character_info.base_expected_points
		expected_points_mod = character_info.base_expected_points_mod
	
	update_score(0)


func update_score(score_add):
	score += score_add
	
	gui_manager.update_score(score, expected_score)


# called at the end of around / start of shop
func increment_counters():
	expected_score += expected_points_mod

	update_score(0)

# called at the start of a round to give live updates on expectations
func add_future_score():
	future_expected_score = expected_score * expected_points_mod
	update_score(0)


# just disabled for right now. reenable as an option like "continue play? or end early" on the victory screen
func has_won_early():
	return false
#	return score >= max_score

func has_lost():
	return score < expected_score


func load_cfg(config: ConfigFile):
	score = config.get_value("scoring", "score")
	expected_score = config.get_value("scoring", "expected_score")
	expected_points_mod = config.get_value("scoring", "expected_points_mod")
	future_expected_score = config.get_value("scoring", "future_expected_score")
	max_score = config.get_value("scoring", "max_score")
func save_cfg(config: ConfigFile):
	config.set_value("scoring", "score", score)
	config.set_value("scoring", "expected_score", expected_score)
	config.set_value("scoring", "expected_points_mod", expected_points_mod)
	config.set_value("scoring", "future_expected_score", future_expected_score)
	config.set_value("scoring", "max_score", max_score)
