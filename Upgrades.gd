##  data relating to integer upgrades to base stats, liek dead wall size.
## most of this is inherited from character_info.
##  should be able to @export and save all of these in future
extends Node
class_name Upgrades

var character_info: CharacterInfo

## these should only change when the game is not active.
func initialize(ch: CharacterInfo):
	character_info = ch

#  amount of tiles to kill at the start. (it's the present value * 3).
# this should be an even number or the dead wall display will break
var dead_wall_size_reduce = 0
func get_dead_tiles():
	return maxi(character_info.dead_wall_size - dead_wall_size_reduce, 0)

# how many discards inbetween each player draw.
var opponent_discard_reduce = 0
func get_discard_count():
	return maxi(0, character_info.discard_count - opponent_discard_reduce)

# how many players you can chii off of
var legal_chis_increase = 0
func get_legal_chis():
	return(character_info.opponents_its_legal_to_chii_from_count + legal_chis_increase)

#  how many dora and ura dora to draw
var BASE_KAN_SIZE = 5
var additional_available_kans = 0
func get_kan_size():
	return BASE_KAN_SIZE + additional_available_kans

#  how many kandora start revealed
var BASE_KAN_REVEALED = 1
var additional_revealed_kandora = 0
func get_kan_revealed():
	return BASE_KAN_REVEALED + additional_revealed_kandora

# how much mana to charge every time the player draws a tile
var mana_gained_on_player_draw = 1
