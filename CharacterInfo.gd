##  container for all of a run's default stats.
## only exception is the wall, which `MahjongManager/TileCounter` generates.
##  NOTHING HERE SHOULD BE MODIFIED!!!!!!
## save all changes to stats here in `MahjongManager/Upgrades`!
extends Node
class_name CharacterInfo

# SICHUAN is prob not goin in the final game, but an 11-size version might
enum TYPES {REGULAR, SANMA, XL, NO_HONORS, SICHUAN}

# use set_type onegaishimasu, the rest will follow
var type: int

var dead_wall_size: int
var discard_count: int
var valid_seats: int
var opponents_its_legal_to_chii_from_count: int
var hand_size: int

var starting_uprgrades: Array #of ints

# scoring expectations
var base_score: int					= 2000
var base_expected_points: int 		= 0
var base_expected_points_mod: int	= 0
var expected_points_mod_mod: int	= 1000

# how many rounds to win the game after
var number_of_rounds: int

# the root name of the variant so we can translate in the 
# name and desc
var tr_root: String

# used to generate the preview at character select
var preview_tile_strings: Array
# same as above, additional field for bonus tiles
var preview_tile_with_strings: Array


# this is ugly but im not putting in a json reader just for this, sorz
func set_type(ty:int):
	type = ty
	match ty:
		TYPES.REGULAR:
			dead_wall_size = 32
			discard_count = 3
			valid_seats = 4
			opponents_its_legal_to_chii_from_count = 1
			hand_size = 14
			
			
			number_of_rounds = 8
			
			tr_root = "CHARACTER_RIICHI"
			
			preview_tile_strings = ["123456789p", "123456789s", "123456789m", "東南西北白發中"]
			preview_tile_with_strings = ["5'p5's5'm白*"]
			
		TYPES.SANMA:
			dead_wall_size = 20
			discard_count = 2
			valid_seats = 3
			opponents_its_legal_to_chii_from_count = 0
			hand_size = 14
			
			starting_uprgrades = [Upgrade.TYPES.UPR_KITA]
			
			
			number_of_rounds = 9
			
			tr_root = "CHARACTER_SANMA"
			
			preview_tile_strings = ["123456789p", "123456789s", "19m", "東南西北白發中"]
			preview_tile_with_strings = ["1\"s"]
			
		TYPES.NO_HONORS:
			dead_wall_size = 32
			discard_count = 3
			valid_seats = 4
			opponents_its_legal_to_chii_from_count = 1
			hand_size = 14
			
			
			number_of_rounds = 8
			
			tr_root = "CHARACTER_NO_HONORS"
			
			preview_tile_strings = ["123456789p", "123456789s", "123456789m", "123456789c"]
			preview_tile_with_strings = [""]
		
		TYPES.XL:
			dead_wall_size = 40
			discard_count = 3
			valid_seats = 4
			opponents_its_legal_to_chii_from_count = 1
			hand_size = 17
			
			starting_uprgrades = [Upgrade.TYPES.UPR_FLOWER, Upgrade.TYPES.UPR_FLOWER, Upgrade.TYPES.UPR_SEASON, Upgrade.TYPES.UPR_SEASON]
			
			number_of_rounds = 8
			
			tr_root = "CHARACTER_XL"
			
			preview_tile_strings = ["123456789p", "123456789s", "123456789m", "東南西北白發中"]
			preview_tile_with_strings = ["12345678f"]
		
		#  apparently this version of this variant is reported by like 1 guy (https://sloperama.com/mjfaq/mjfaq02b.html),
		# probably super local. this is temp but i like the idea of an 11-size char
		TYPES.SICHUAN:
			dead_wall_size = 8
			discard_count = 3
			valid_seats = 4
			opponents_its_legal_to_chii_from_count = 1
			hand_size = 11
			
			
			number_of_rounds = 8
			
			tr_root = "CHARACTER_SICHUAN"
			
			preview_tile_strings = ["123456789p", "123456789s"]
			preview_tile_with_strings = [""]
