extends Control

@onready var name_label = $VBoxContainer/HBoxContainer/NameLabel
@onready var han_label = $VBoxContainer/HBoxContainer/HanLabel
@onready var desc_label = $VBoxContainer/DescLabel
@onready var closed_label = $VBoxContainer/HBoxContainer/ClosedLabel

func set_info(info: ScoringInfo.Han):
	name_label.text = info.nam
	han_label.text = "[%d]" % info.han
	
	if info.han - info.open_penalty <= 0:
		closed_label.text = " (Closed Only) "
	elif info.open_penalty!= 0:
		closed_label.text = " (-%d if Open) " % info.open_penalty
	else:
		closed_label.text = ""
	desc_label.text = info.desc
