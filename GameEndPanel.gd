extends PanelContainer
class_name GameEndPanel

class FinishInfo:
	var win: bool
	var points: int
	var expected_points: int
	var round: int
	var expected_round: int

@onready var title = $VBoxContainer/Title
@onready var description = $VBoxContainer/Description


func display(fi: FinishInfo):
	get_parent().visible = true
	if fi.win:
		title.text = tr("GAME_END_WIN")
	else:
		title.text = tr("GAME_END_LOSE")
	
	description.text = tr("GAME_END_SCORE") + ": " + ("%d/%d" % [fi.points, fi.expected_points]) + "\n"
	description.text += tr("GAME_END_ROUND") + ": " + ("%d/%d" % [fi.round, fi.expected_round])
