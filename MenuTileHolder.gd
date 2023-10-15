extends HBoxContainer

@export var suit = MTile.SUITS.MAN
@export var tile_graphic = preload("res://TileGraphic.tscn")

@onready var tile_counter = $"../../../../../MahjongRoot/MahjongManager/TileCounter"

func _ready():
	for i in 9 if suit != MTile.SUITS.SPECIAL else MTile.SPECIALS.size()-1:
		for mtd in tile_counter.tile_data:
			if mtd.suit == suit and mtd.value == i+1:
				var t = tile_graphic.instantiate()
				add_child(t)
				t.assign_suit_value(MTile.new(suit,i+1))
				break
		
