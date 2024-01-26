extends Control

# assigned by parent on instantiation
@onready var mahjong_manager
@onready var calls = $".."
@onready var hand = $"../../All/SideSpacers/Tiles/HBoxContainer/Hand"
var rich_text_label

@export var bitmask: MahjongManager.CALL_BITMASK
var _tiles_involved = []

var CALL_NAMES = {
	MahjongManager.CALL_BITMASK.NONE: "None",
	MahjongManager.CALL_BITMASK.CHI_L: tr("CALL_CHI_L"),
	MahjongManager.CALL_BITMASK.CHI_M: tr("CALL_CHI_M"),
	MahjongManager.CALL_BITMASK.CHI_R: tr("CALL_CHI_L"),
	MahjongManager.CALL_BITMASK.PON: tr("CALL_PON"),
	MahjongManager.CALL_BITMASK.KAN: tr("CALL_KAN"),
	MahjongManager.CALL_BITMASK.RON: tr("CALL_RON"),
	MahjongManager.CALL_BITMASK.TSM: tr("CALL_TSUMO"),
	MahjongManager.CALL_BITMASK.CLOSED_KAN: tr("CALL_KAN"),
	MahjongManager.CALL_BITMASK.RCH: tr("CALL_RIICHI"),
	MahjongManager.CALL_BITMASK.FLOWER: tr("CALL_FLOWER"),
	MahjongManager.CALL_BITMASK.KITA: tr("CALL_KITA"),
}

# call BEFORE `_ready()`! also assign bitmask!
func assign_nodes(mm: Node, clls: Node, hnd: Node):
	mahjong_manager = mm
	calls = clls
	hand = hand

func _ready():
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	
	if bitmask != MahjongManager.CALL_BITMASK.NONE:
		rich_text_label = $RichTextLabel
		rich_text_label.text = CALL_NAMES[bitmask]
		# gild certain buttons
		if [MahjongManager.CALL_BITMASK.FLOWER, MahjongManager.CALL_BITMASK.RCH, MahjongManager.CALL_BITMASK.TSM, MahjongManager.CALL_BITMASK.RON].has(bitmask):
			get_theme_stylebox("panel").region_rect.position.x = 38
			rich_text_label.add_theme_color_override("font_color", Color(COL.BLACK))
			#rich_text_label.label_settings.font_color = Color(COL.BLACK)

func enable(bm: int, tiles_involved: Dictionary):
	visible = bm & bitmask
	visible = visible or ((bitmask == MahjongManager.CALL_BITMASK.NONE) and (bm != 0))
	
	if visible and bitmask != MahjongManager.CALL_BITMASK.NONE:
		animate()
	
	if tiles_involved.has(bitmask):
		_tiles_involved = tiles_involved[bitmask]
	else:
		_tiles_involved = []

func _gui_input(event):
	# clicking
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_mouse_exited()
			mahjong_manager.call_graphic_clicked(bitmask,_tiles_involved)
			#calls.enable_calls(0, {})

# only called for calls other than NONE
func animate():
	rich_text_label.visible = false
	get_theme_stylebox("panel").region_rect.position.y = 16
	await AnimTimer.start_mod(.08)
	rich_text_label.visible = true
	get_theme_stylebox("panel").region_rect.position.y = 0
	

# tells the hand to tell relevant tiles to highlight themselves
func _on_mouse_entered():
	var highlight_most_recent_disc = [
		MahjongManager.CALL_BITMASK.CHI_L,
		MahjongManager.CALL_BITMASK.CHI_M,
		MahjongManager.CALL_BITMASK.CHI_R,
		MahjongManager.CALL_BITMASK.PON,
		MahjongManager.CALL_BITMASK.KAN,
		MahjongManager.CALL_BITMASK.RON
	].has(bitmask)
	hand.highlight_relevant_tiles(_tiles_involved, highlight_most_recent_disc, true)
func _on_mouse_exited():
	var highlight_most_recent_disc = [
		MahjongManager.CALL_BITMASK.CHI_L,
		MahjongManager.CALL_BITMASK.CHI_M,
		MahjongManager.CALL_BITMASK.CHI_R,
		MahjongManager.CALL_BITMASK.PON,
		MahjongManager.CALL_BITMASK.KAN,
		MahjongManager.CALL_BITMASK.RON
	].has(bitmask)
	hand.highlight_relevant_tiles([], highlight_most_recent_disc, false)
