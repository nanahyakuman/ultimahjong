extends Node

@onready var gui_manager = $"../HBoxContainer/MahjongRoot/GUIManager"

var score = 0

var expected_score = 0
var expected_points_mod = 0
var expected_points_mod_mod = 0

func initialize(character_info: CharacterInfo):
	score = character_info.base_score
	expected_score = character_info.base_expected_points
	expected_points_mod = character_info.base_expected_points_mod
	expected_points_mod_mod = character_info.expected_points_mod_mod
	
	gui_manager.update_score(score, expected_score, expected_points_mod, expected_points_mod_mod)

func update_score(score_add: int):
	score += score_add
	
	gui_manager.update_score(score, expected_score, expected_points_mod, expected_points_mod_mod)
	

func increment_counters():
	expected_points_mod += expected_points_mod_mod
	expected_score += expected_points_mod
	
	#assert(score >= expected_score)
	
	gui_manager.update_score(score, expected_score, expected_points_mod, expected_points_mod_mod)
