extends Node

@onready var gui_manager = $"../HBoxContainer/MahjongRoot/GUIManager"
@onready var root = $".."

var score = 0
var expected_score = 0
var expected_points_mod = 0
var expected_points_mod_mod = 0
# precalculated to give the player warning
var future_expected_score = 0

var max_score = 0
 
# kept so we can reference constants
var ci: CharacterInfo

func initialize(character_info: CharacterInfo, load: bool):
	ci = character_info
	if !load:
		score = character_info.base_score
		expected_score = character_info.base_expected_points
		expected_points_mod = character_info.base_expected_points_mod
		expected_points_mod_mod = character_info.expected_points_mod_mod
		future_expected_score = character_info.expected_points_mod_mod
	
	update_score(0)


func update_score(score_add: int):
	score += score_add
	
	gui_manager.update_score(score, future_expected_score, expected_points_mod, expected_points_mod_mod)


# called at the end of around / start of shop
func increment_counters():
	expected_points_mod += expected_points_mod_mod
	expected_score += expected_points_mod
	
	#  i know gauss's would be faster but it doesn't account for changes in acceleration
	# like i may implement in future
	var max_score = expected_score
	for i in ci.number_of_rounds - root.round_counter:
		max_score += expected_points_mod + expected_points_mod_mod * i
	if score >= max_score:
		# trigger win screen
		pass
	
	if score < expected_score:
		# trigger lose screen
		pass
	
	update_score(0)


# called at the start of a round to give live updates on expectations
func add_future_score():
	future_expected_score = expected_score + expected_points_mod + expected_points_mod_mod
	update_score(0)


func load_cfg(config: ConfigFile):
	score = config.get_value("scoring", "score")
	expected_score = config.get_value("scoring", "expected_score")
	expected_points_mod = config.get_value("scoring", "expected_points_mod")
	expected_points_mod_mod = config.get_value("scoring", "expected_points_mod_mod")
	future_expected_score = config.get_value("scoring", "future_expected_score")
	max_score = config.get_value("scoring", "max_score")
func save_cfg(config: ConfigFile):
	config.set_value("scoring", "score", score)
	config.set_value("scoring", "expected_score", expected_score)
	config.set_value("scoring", "expected_points_mod", expected_points_mod)
	config.set_value("scoring", "expected_points_mod_mod", expected_points_mod_mod)
	config.set_value("scoring", "future_expected_score", future_expected_score)
	config.set_value("scoring", "max_score", max_score)
