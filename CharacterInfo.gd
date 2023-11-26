##  container for all of a run's default stats.
## only exception is the wall, which `MahjongManager/TileCounter` generates.
extends Node
class_name CharacterInfo

enum {REGULAR, SANMA}

# use set_type onegaishimasu, the rest will follow
var type: int

var dead_wall_size: int
var discard_count: int
var valid_seats: int
var opponents_its_legal_to_chii_from_count: int

# scoring expectations
var base_score: int
var base_expected_points: int
var base_expected_points_mod: int
var expected_points_mod_mod: int

# how many rounds to win the game after
var number_of_rounds: int

func set_type(ty:int):
	match ty:
		REGULAR:
			type = REGULAR
			dead_wall_size = 32
			discard_count = 3
			valid_seats = 4
			opponents_its_legal_to_chii_from_count = 1
			
			base_score = 2000
			base_expected_points = 0
			base_expected_points_mod = 0
			expected_points_mod_mod = 500
			
			number_of_rounds = 16
		SANMA:
			type = SANMA
			dead_wall_size = 20
			discard_count = 2
			valid_seats = 3
			opponents_its_legal_to_chii_from_count = 0
			
			base_score = 2000
			base_expected_points = 0
			base_expected_points_mod = 0
			expected_points_mod_mod = 500
			
			number_of_rounds = 18
