extends Node

enum SUITS {MAN=1, SOU=2, PIN=4, SPECIAL=8}
enum SPECIALS {HAKU, HATSU, CHUN, NORTH, EAST, SOUTH, WEST}
const SPEC_VALS = ["[", "]", "|", "@", "#", "$", "!"]
#const SPEC_VALS = ["u", "s"," t",   "w", "x", "y", "z"]
#const TOP_ROW = ["q", "w", "e", "r", "t", "y", "u", "i", "o"]
const ALPH = ["a", "b", "c", "d", "e", "f", "g", "h", "i"]
#const MID_ROW = ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
const ALPH2 = ["r", "s", "t", "u", "v", "w", "x", "y", "z"]
#stuvwxyz


class MTile:
	var suit: int
	var value: int
	
	var aka: bool = false
	
	func _init(s:int,v:int):
		suit = s
		value = v
	
	func get_str():
		if suit != SUITS.SPECIAL:
			if suit == SUITS.MAN:
				var offset = "1".unicode_at(0)-1
				return char(offset+value)
			elif suit == SUITS.SOU:
				return(ALPH[value-1])
			elif suit == SUITS.PIN:
				var ret = ALPH2[value-1].to_upper()
				return(ret)
		else:
			return SPEC_VALS[value]
	
	func get_order():
		return suit * 100 + value * 10 + int(aka)


@onready var hand_label = $"../HandLabel"
@onready var tsumo_label = $"../TsumoLabel"
@onready var input_label = $"../InputLabel"


var wall = []
var hand = []
var tsumo
var discard = []

func _ready():
	input_label.grab_click_focus()
	
	init_wall()
	
	draw_hand()
	draw_tile()
	
# default tiles
func init_wall():
	for i in SUITS.values():
		if i == SUITS.SPECIAL:
			for j in SPECIALS.values():
				wall.append(MTile.new(i,j))
		else:
			for j in range(1,10):
				wall.append(MTile.new(i,j))
	
	# this gives me anxiety but appears safe
	wall.append_array(wall)
	wall.append_array(wall)
	wall.shuffle()

func draw_hand():
	for i in 13:
		hand.append(wall.pop_back())
	update_hand_label()

func draw_tile():
	tsumo = wall.pop_back()
	tsumo_label.text = tsumo.get_str()



#func _unhandled_input(event):
#	if event is InputEventKey:
#		if event.pressed:
#			var code = OS.get_keycode_string(event.keycode).to_lower()
#
#			print(code)
#
#			var extant = tsumo if tsumo.get_str().to_lower() == code else null
#			if !extant:
#				for t in hand:
#					if t.get_str().to_lower() == code:
#						extant = t
#						break
#
#			if extant:
#				hand.append(tsumo)
#				hand.erase(extant)
#				update_hand_label()
#				draw_tile()

func _process(delta):
	if input_label.text.length() > 0:
		var code = input_label.text[0].to_lower()
		
		var extant = tsumo if tsumo.get_str().to_lower() == code else null
		if !extant:
			for t in hand:
				if t.get_str().to_lower() == code:
					extant = t
					break

		if extant:
			hand.append(tsumo)
			hand.erase(extant)
			update_hand_label()
			draw_tile()
		
		input_label.text = ""



func update_hand_label():
	hand.sort_custom(Callable(self, "tile_compare"))
	
	hand_label.text = get_tiles_as_str(hand)




func get_tiles_as_str(tiles: Array):
	var str = ""
	for t in tiles:
		str += t.get_str()
	return str

func tile_compare(a:MTile, b:MTile):
	return a.get_order() < b.get_order()
