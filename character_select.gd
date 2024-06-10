extends Control

var char_info: CharacterInfo

@onready var name_label = $VBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/PanelContainer2/HBoxContainer/PanelContainer/Name
@onready var desc_label = $VBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/Desc
@onready var tile_grid_container = $VBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer/TileGridContainer
@onready var tile_grid_container_with = $VBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer2/TileGridContainer

@onready var texture_button = $VBoxContainer/PanelContainer/HBoxContainer/TextureButton
@onready var texture_button_2 = $VBoxContainer/PanelContainer/HBoxContainer/TextureButton2

# override to hide unfinished characters
var DISPLAY_AMOUNT = 4

func _ready():
	change_char(CharacterInfo.TYPES.REGULAR)

func change_char(type: int):
	char_info = CharacterInfo.new()
	char_info.set_type(type)
	name_label.text = tr(char_info.tr_root+"_NAME")
	
	CharInfoForwarder.ci = char_info
	
	desc_label.clear()
	desc_label.append_text(tr(char_info.tr_root+"_DESC"))
	
	tile_grid_container.generate(char_info.preview_tile_strings)
	
	tile_grid_container_with.generate(char_info.preview_tile_with_strings)
	
	texture_button.disabled = !(char_info.type > 0)
	texture_button_2.disabled = !(char_info.type < DISPLAY_AMOUNT-1)


func start_pressed():
	CharInfoForwarder.load = false
	get_tree().change_scene_to_packed(load("res://root.tscn"))
