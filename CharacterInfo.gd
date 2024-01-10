##  container for all of a run's default stats.
## only exception is the wall, which `MahjongManager/TileCounter` generates.
extends Node
class_name CharacterInfo

enum TYPES {REGULAR, SANMA, NO_HONORS}

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

# the root name of the variant so we can translate in the 
# name and desc
var tr_root: String

# used to generate the preview at character select
var preview_tile_strings: Array

# this is ugly but im not putting in a json reader just for this, sorz
func set_type(ty:int):
	match ty:
		TYPES.REGULAR:
			type = TYPES.REGULAR
			dead_wall_size = 32
			discard_count = 3
			valid_seats = 4
			opponents_its_legal_to_chii_from_count = 1
			
			base_score = 2000
			base_expected_points = 0
			base_expected_points_mod = 0
			expected_points_mod_mod = 500
			
			number_of_rounds = 16
			
			tr_root = "CHARACTER_RIICHI"
			
			preview_tile_strings = ["123456789p", "123456789s", "123456789m", "東南西北白發中"]
			
		TYPES.SANMA:
			type = TYPES.SANMA
			dead_wall_size = 20
			discard_count = 2
			valid_seats = 3
			opponents_its_legal_to_chii_from_count = 0
			
			base_score = 2000
			base_expected_points = 0
			base_expected_points_mod = 0
			expected_points_mod_mod = 500
			
			number_of_rounds = 18
			
			tr_root = "CHARACTER_SANMA"
			
			preview_tile_strings = ["123456789p", "123456789s", "19m", "東南西北白發中"]
		
		TYPES.NO_HONORS:
			type = TYPES.NO_HONORS
			dead_wall_size = 20
			discard_count = 3
			valid_seats = 4
			opponents_its_legal_to_chii_from_count = 1
			
			base_score = 2000
			base_expected_points = 0
			base_expected_points_mod = 0
			expected_points_mod_mod = 500
			
			number_of_rounds = 16
			
			tr_root = "CHARACTER_NO_HONORS"
			
