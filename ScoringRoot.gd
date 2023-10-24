extends Control
@onready var han_names = $Window/VBoxContainer/Han/Names
@onready var han_points = $Window/VBoxContainer/Han/Points
@onready var fu_names = $Window/VBoxContainer/Fu/Names
@onready var fu_points = $Window/VBoxContainer/Fu/Points
@onready var calc = $Window/VBoxContainer/Calc


# fu, han, and points can theoretically be derived here but
# why do it twice
func update_scoring(scoring_info: ScoringInfo, fu: int, han: int, points:int, mult: int):
	han_names.clear()
	han_points.clear()
	han_points.append_text("[right]")
	for h in scoring_info.hans:
		han_names.append_text(h.nam + "\n")
		han_points.append_text(str(h.han) + " han\n")
	
	fu_names.clear()
	fu_points.clear()
	fu_points.append_text("[right]")
	for f in scoring_info.fus:
		if f.fu == 0:
			continue
		fu_names.append_text(f.nam + "\n")
		fu_points.append_text(str(f.fu) + " fu\n")
	
	calc.clear()
	calc.text = "[center][b]%d×2[/b](2+%d)[b]×%d=\n%d" % [fu, han, mult, points]
