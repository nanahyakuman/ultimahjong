extends Control
@onready var gui_manager = $"../GUIManager"
@onready var han_names = $Window/VBoxContainer/Han/Names
@onready var han_points = $Window/VBoxContainer/Han/Points
@onready var fu_names = $Window/VBoxContainer/Fu/Names
@onready var fu_points = $Window/VBoxContainer/Fu/Points
@onready var chip_names = $Window/VBoxContainer/Chips/Names
@onready var chip_points = $Window/VBoxContainer/Chips/Points
@onready var calc = $Window/VBoxContainer/Calc
@onready var total = $Window/VBoxContainer/Total
@onready var score_label = $"../GUIManager/TableTop/HBoxContainer/HBoxContainer/ScoreLabel"
@onready var open_shop_button = $OpenShopButton


@export var animate = true

# fu, han, and points can theoretically be derived here but
# why do it twice
func update_scoring(scoring_info: ScoringInfo, _fu: int, _han: int, _chips: int, points, mult):
	han_names.clear()
	han_points.clear()
	fu_names.clear()
	fu_points.clear()
	chip_names.clear()
	chip_points.clear()
	calc.clear()
	total.clear()
	
	# cant skip anim
	open_shop_button.visible = false
	
	fu_points.append_text("[right][color=%s]" % COL.LBLUE)
	for f in scoring_info.fus:
		if f.fu == 0:
			continue
		fu_names.append_text(tr(f.nam) + "\n")
		fu_points.append_text(str(f.fu) + " fu\n")
		if animate:
			await AnimTimer.start_get(.1)
	
	han_points.append_text("[right][color=%s]" % COL.YELLOW)
	for h in scoring_info.hans:
		var han_count = h.calc_han(scoring_info.open)
		# ignore non-scoring han, e.g. open pinfu, open menzentsumo
		if han_count == 0:
			continue
		
		han_names.append_text(tr(h.nam) + "\n")
		han_points.append_text(str(han_count) + " han\n")
		if animate:
			for i in han_count: 
				MusicManager.play_han()
				await AnimTimer.start_get(.15)
			await AnimTimer.start_get(.3)
		if !animate: #only queue once if not animating, should prevent weird transients
			MusicManager.play_han()
	
	chip_points.append_text("[right][color=%s]" % COL.LGREEN)
	for c in scoring_info.chips:
		chip_names.append_text(tr(c.nam) + "\n")
		chip_points.append_text("%d pts\n" % ScoringInfo.CHIP_VALUE)
		if animate:
			await AnimTimer.start_get(.1)
	
	await AnimTimer.start_get(.3, true)
	
	#calc.text = "[center][b][color=%s]%d[/color]×2[/b](2+[color=%s]%d[/color])[b]×%d=" % [COL.LBLUE, fu, COL.YELLOW, han, mult]
	#calc.visible = false
	total.set_text_colorized(points)
	
	
	if points > 0:
		MusicManager.start_win()
	
	open_shop_button.visible = true
