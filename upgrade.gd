##  persistant upgrades. structured weirdwsly ngl. 'tworks tho
extends CursorTextRequester
class_name Upgrade

# pooled by upgradegridcontainer, using the metadata below
enum TYPES {UPR_NONE, UPR_DEAD_REDUCE, UPR_KAN_REVEAL, UPR_KITA, UPR_OPPONENT_KILL,
	UPR_MANA_UP, UPR_RONANKOU, UPR_STRONGER_RIICHI, UPR_MORE_MONEY, UPR_FLOWER, UPR_SEASON,
	UPR_KIN_DRAGON, UPR_RISING_WIND, UPR_DECEL, UPR_MORE_DRAGONS, UPR_TENS}
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
	TYPES.UPR_RONANKOU:			[2, 1],
	TYPES.UPR_STRONGER_RIICHI:	[2, 3],
	TYPES.UPR_MORE_MONEY:		[4, 1],
	TYPES.UPR_FLOWER:			[2, 2],
	TYPES.UPR_SEASON:			[2, 2],
	TYPES.UPR_KIN_DRAGON:		[4, 1],
	TYPES.UPR_RISING_WIND:		[4, 1],
	TYPES.UPR_DECEL:			[2, 0], # muted rn bc it's kinda lame, and because the gui doesnt update right atm
	TYPES.UPR_MORE_DRAGONS:		[1, 4],
	TYPES.UPR_TENS:				[1, 4],
}
var type = TYPES.UPR_NONE

@onready var sprite_2d = $Sprite2D

func _ready():
	super._ready()
	
	# hacky but works
	var string_id = TYPES.keys()[type]
	hover_text = tr(string_id)
	
	sprite_2d.frame = type


#  called when bought (and on reload). load_mute` is for upgrades that
# just add tiles, bc tile management is already handled by the tilecounter
func bought(upgrades: Upgrades, tile_counter: Node, score_tracker: Node, load_mute: bool):
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
			#  this actually robs you of your fu on menzenkafu ig, but its
			# probably best to keep it that way for consistency
			upgrades.ron_counted_as_tsumo = true
		TYPES.UPR_STRONGER_RIICHI:
			upgrades.riichi_multiplier += 1
		TYPES.UPR_MORE_MONEY:
			upgrades.additional_money_per_round += 1
		TYPES.UPR_FLOWER:
			if !load_mute:
				tile_counter.add_flowers(2, false)
		TYPES.UPR_SEASON:
			if !load_mute:
				tile_counter.add_flowers(2, true)
		TYPES.UPR_KIN_DRAGON:
			if !load_mute:
				for i in 4:
					tile_counter.increment_tile(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.KIN))
		TYPES.UPR_RISING_WIND:
			if !load_mute:
				for i in 4:
					tile_counter.increment_tile(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.UP))
		TYPES.UPR_DECEL:
			score_tracker.expected_points_mod_mod -= 200
		TYPES.UPR_MORE_DRAGONS:
			if !load_mute:
				tile_counter.increment_tile(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HAKU))
				tile_counter.increment_tile(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.HATSU))
				tile_counter.increment_tile(MTile.new(MTile.SUITS.SPECIAL, MTile.SPECIALS.CHUN))
		TYPES.UPR_TENS:
			if !load_mute:
				for i in [MTile.SUITS.PIN, MTile.SUITS.SOU, MTile.SUITS.MAN]:
					for j in 1:
						tile_counter.increment_tile(MTile.new(i, 10))


