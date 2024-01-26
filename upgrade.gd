##  persistant upgrades. structured weirdwsly because its a mix of gutted purchaseable
## code and gutted item code.
extends CursorTextRequester
class_name Upgrade

# pooled by upgradegridcontainer.
enum TYPES {UPR_NONE, UPR_DEAD_REDUCE, UPR_KAN_REVEAL, UPR_KITA, UPR_OPPONENT_KILL, UPR_MANA_UP, UPR_RONANKOU, UPR_STRONGER_RIICHI, UPR_MORE_MONEY, UPR_FLOWER, UPR_SEASON, UPR_KIN_DRAGON, UPR_RISING_WIND}
#  metadata about items.
# generally want these to cost 2, but probably go all the way up to 5.
# 3+ end the shop unceremoniously so taitei to be avoided
enum {METADATA_COST = 0, METADATA_COUNT = 1}
const METADATA = {		# cost, pool size
	TYPES.UPR_DEAD_REDUCE:		[1, 0], # never chosen by pool, just shows up until there's no point buying more
	TYPES.UPR_KAN_REVEAL:		[2, 4],
	TYPES.UPR_KITA:				[4, 1],
	TYPES.UPR_OPPONENT_KILL:	[5, 1],
	TYPES.UPR_MANA_UP:			[2, 2],
	TYPES.UPR_RONANKOU:			[1, 1],
	TYPES.UPR_STRONGER_RIICHI:	[2, 3],
	TYPES.UPR_MORE_MONEY:		[4, 1],
	TYPES.UPR_FLOWER:			[2, 2],
	TYPES.UPR_SEASON:			[2, 2],
	TYPES.UPR_KIN_DRAGON:		[4, 1],
	TYPES.UPR_RISING_WIND:		[4, 1],
}
var type = TYPES.UPR_NONE

@onready var sprite_2d = $Sprite2D

func _ready():
	super._ready()
	
	# hacky but works
	var string_id = TYPES.keys()[type]
	hover_text = tr(string_id)
	
	sprite_2d.frame = type


# called when bought. (and on reload)
func bought(upgrades: Upgrades, tile_counter: Node):
	assert(type != TYPES.UPR_NONE, "not a valid upgrade!")
	match type:
		TYPES.UPR_DEAD_REDUCE:
			upgrades.dead_wall_size_reduce += 4
		TYPES.UPR_KAN_REVEAL:
			upgrades.additional_revealed_kandora += 1
		TYPES.UPR_KITA:
			upgrades.can_kita_nuki = true
		TYPES.UPR_OPPONENT_KILL:
			upgrades.opponent_discard_reduce = 1
		TYPES.UPR_MANA_UP:
			upgrades.mana_gained_on_player_draw += 1
		TYPES.UPR_RONANKOU:
			#  this actually robs you of 8fu on menzenkafu ig, but its
			# probably best to keep it that way for consistency
			upgrades.ron_counted_as_tsumo = true
		TYPES.UPR_STRONGER_RIICHI:
			upgrades.riichi_multiplier += 1
		TYPES.UPR_MORE_MONEY:
			upgrades.additional_money_per_round += 1
		TYPES.UPR_FLOWER:
			tile_counter.add_flowers(2, false)
		TYPES.UPR_SEASON:
			tile_counter.add_flowers(2, true)
		TYPES.UPR_KIN_DRAGON:
			for i in 4:
				tile_counter.increment_tile(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.KIN))
		TYPES.UPR_RISING_WIND:
			for i in 4:
				tile_counter.increment_tile(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.UP))
			
