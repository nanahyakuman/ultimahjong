extends Control

@onready var name_label = $VBoxContainer/Panel/HBoxContainer/NameLabel
@onready var han_label = $VBoxContainer/Panel/HBoxContainer/HanLabel
@onready var desc_label = $VBoxContainer/DescLabel
@onready var translit_label = $VBoxContainer/TranslitLabel
@onready var closed_label = $VBoxContainer/Panel/HBoxContainer/ClosedLabel
@onready var tile_label = $VBoxContainer/TileLabel
@onready var easy_texture_rect = $VBoxContainer/Panel/HBoxContainer/EasyTextureRect

func set_info(info: ScoringInfo.Han):
	name_label.text = info.nam
	if info.closed_han < 13:
		han_label.text = "[%d]" % info.closed_han
	else:
		han_label.text = "[]"
		for i in info.closed_han / 13:
			han_label.text = han_label.text.insert(1, "Y")
	
	if info.closed_han - info.open_penalty <= 0:
		closed_label.text = " (Closed Only) "
	elif info.open_penalty!= 0:
		closed_label.text = " (-%d Open) " % info.open_penalty
	else:
		closed_label.text = ""
	
	easy_texture_rect.visible = info.easy
	
	desc_label.clear()
	desc_label.append_text(tr(info.TR_KEY + "_DESC"))
	translit_label.clear()
	translit_label.append_text("[i]" + tr(info.TR_KEY + "_LIT"))
	tile_label.text = info.graphic_desc
	
	if tile_label.text.length() < 14:
		while tile_label.text.length() < 13:
			tile_label.text += "🀪"
		tile_label.text += " 🀪"
