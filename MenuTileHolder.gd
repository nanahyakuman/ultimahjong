extends HBoxContainer

@export var suit = MTile.SUITS.MAN
@export var tile_graphic = preload("res://TileGraphic.tscn")

func _ready():
	for i in 9 if suit != MTile.SUITS.SPECIAL else MTile.SPECIALS.size()-1:
		var t = tile_graphic.instantiate()
		add_child(t)
		t.assign_suit_value(MTile.new(suit,i+1))
		
