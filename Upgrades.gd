extends Node

## these should only change when the game is not active.

#  amount of tiles to kill at the start. (it's the present value * 3).
# this should be an even number or the dead wall display will break
const TILES_DEAD_PER_4_PLAYER_DRAWS = 36
@export var dead_wall_size_reduce = 0
func get_dead_tiles():
	return maxi(TILES_DEAD_PER_4_PLAYER_DRAWS - dead_wall_size_reduce, 0)

#  how many dora and ura dora to draw
const BASE_KAN_SIZE = 5
@export var additional_available_kans = 0
func get_kan_size():
	return BASE_KAN_SIZE + additional_available_kans

#  how many kandora start revealed
const BASE_KAN_REVEALED = 1
@export var additional_revealed_kandora = 0
func get_kan_revealed():
	return BASE_KAN_REVEALED + additional_revealed_kandora


# how many discards inbetween each player draw
const OPPONENT_DISCARDS = 3
@export var opponent_discard_reduce = 0
func get_discard_count():
	return maxi(0, OPPONENT_DISCARDS - opponent_discard_reduce)
