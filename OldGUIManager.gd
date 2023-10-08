extends Control

@onready var hand_label = $VBoxContainer/HBoxContainer/HandLabel
@onready var hand_label_2 = $VBoxContainer/HBoxContainer2/HandLabel2
@onready var tsumo_label = $VBoxContainer/HBoxContainer/TsumoLabel
@onready var tsumo_label_2 = $VBoxContainer/HBoxContainer2/TsumoLabel2
@onready var input_label = $VBoxContainer/InputLabel
@onready var discard_label = $VBoxContainer/DiscardLabel
@onready var discard_label_2 = $VBoxContainer/DiscardLabel2
@onready var kan_label = $VBoxContainer/KanLabel
@onready var kan_label_2 = $VBoxContainer/KanLabel2

const SIZE = 20
@onready var opp_labels = [$VBoxContainer/DiscardLabel3,$VBoxContainer/DiscardLabel4,$VBoxContainer/DiscardLabel5, $VBoxContainer/DiscardLabel6,$VBoxContainer/DiscardLabel7, $VBoxContainer/DiscardLabel8]


func _ready():
	input_label.grab_focus()

func update_hand(hand):
	#hand_label.text = MTile.get_tiles_as_str(hand)
	var str = ""
	var str2 = ""
	for t in hand:
		var a = t.get_display_strs()
		str += a[0]
		str2 += a[1]
	hand_label.clear()
	hand_label.append_text(str)
	hand_label_2.clear()
	hand_label_2.append_text(str2)

func update_discard(discard):
	var str = ""
	var str2 = ""
	for t in min(discard.size(), 22):
		var a = discard[t].get_display_strs()
		str += a[0]
		str2 += a[1]
	discard_label.clear()
	discard_label.append_text(str)
	discard_label_2.clear()
	discard_label_2.append_text(str2)

func update_opp_discard(opp_discard):
	var strs = []
	strs.resize(opp_labels.size()*2)
	strs.fill("")
	for i in opp_labels.size():
		for t in range(i*SIZE, min(opp_discard.size()-SIZE*i, SIZE) + i*SIZE):
			var a = opp_discard[t].get_display_strs()
			strs[2*i] += a[0]
			strs[2*i+1] += a[1]
	
	for i in opp_labels.size():
		opp_labels[i].clear()
		opp_labels[i].append_text(strs[i])


func update_tsumo(tsumo):
	var str = ""
	var str2 = ""
	var a = tsumo.get_display_strs()
	str += a[0]
	str2 += a[1]
	tsumo_label.clear()
	tsumo_label.append_text(str)
	tsumo_label_2.clear()
	tsumo_label_2.append_text(str2)

func update_kan_dora(kan_dora):
	var str = ""
	var str2 = ""
	for t in kan_dora:
		var a = t.get_display_strs()
		str += a[0]
		str2 += a[1]
	kan_label.clear()
	kan_label.append_text(str)
	kan_label_2.clear()
	kan_label_2.append_text(str2)
