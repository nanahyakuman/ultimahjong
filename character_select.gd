extends Control

var char_info: CharacterInfo

@onready var name_label = $PanelContainer/HBoxContainer/VBoxContainer/PanelContainer2/HBoxContainer/PanelContainer/Name
@onready var desc_label = $PanelContainer/HBoxContainer/VBoxContainer/Desc
@onready var tile_grid_container = $PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer/TileGridContainer

func _ready():
	char_info = CharacterInfo.new()
	change_char(CharacterInfo.TYPES.REGULAR)

func change_char(type: int):
	char_info.set_type(type)
	name_label.text = tr(char_info.tr_root+"_NAME")
	
	desc_label.clear()
	desc_label.append_text(tr(char_info.tr_root+"_DESC"))
	
	tile_grid_container.generate(char_info.preview_tile_strings)
