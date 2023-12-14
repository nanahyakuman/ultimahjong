extends Control

@onready var name_label = $VBoxContainer/HBoxContainer/NameLabel
@onready var han_label = $VBoxContainer/HBoxContainer/HanLabel
@onready var desc_label = $VBoxContainer/DescLabel
@onready var closed_label = $VBoxContainer/HBoxContainer/ClosedLabel
@onready var tile_label = $VBoxContainer/TileLabel

func set_info(info: ScoringInfo.Han):
	name_label.text = info.nam
	han_label.text = "[%d]" % info.closed_han
	
	if info.closed_han - info.open_penalty <= 0:
		closed_label.text = " (Closed Only) "
	elif info.open_penalty!= 0:
		closed_label.text = " (-%d Open) " % info.open_penalty
	else:
		closed_label.text = ""
	desc_label.clear()
	desc_label.append_text(info.desc)
	tile_label.text = info.graphic_desc
	if tile_label.text.length() < 14:
		while tile_label.text.length() < 13:
			tile_label.text += "🀪"
		tile_label.text += " 🀪"
