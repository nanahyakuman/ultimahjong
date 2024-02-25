extends PanelContainer
@onready var h_box_container = $HBoxContainer
@onready var index_container = $"../../IndexContainer"
@onready var ind = preload("res://misc/scoring_graph/graph_index.tscn")
@onready var x_labels = $"../XLabels"
@onready var y_labels = $"../../YLabels"

var fus = [20, 30, 40, 50, 60, 70, 80, 90, 100, 110]
var cols = [COL.BLACKP,COL.BLACKPP,COL.GREEN,COL.RED,COL.AQUA,COL.ORANGE,COL.LBLUE,COL.YELLOW,COL.LGREEN,COL.LRED]

func _ready():
	await get_tree().process_frame
	
	var curr_container = h_box_container
	
	fus.reverse()
	cols.reverse()
	
	# xlabels
	for i in 13:
		var a = Label.new()
		a.text = str(i+1) + " Han"
		a.custom_minimum_size.x = 32
		a.add_theme_color_override("font_color", Color("222222"))
		x_labels.add_child(a)
	
	# ylabels
	for i in range(32000, 0, -4000):
		var a = Label.new()
		a.text = str(i)
		a.custom_minimum_size.y = 40
		a.add_theme_color_override("font_color", Color("222222"))
		y_labels.add_child(a)
	
	for i in fus.size():
		for han in 13:
			var points = ScoringInfo._alt_points_count(fus[i]-20, han+1, 0)
			# assuming ko ron
			points = ScoringInfo.round_to_place(points * (4), 100)
			
			var a = ColorRect.new()
			a.color = Color(cols[i])
			a.custom_minimum_size.x = 28
			a.custom_minimum_size.y = points/100
			
			a.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			a.size_flags_vertical = Control.SIZE_SHRINK_END
			
			curr_container.add_child(a)
			
			# seperation not working 
			var b = Control.new()
			b.custom_minimum_size.x = 4
			curr_container.add_child(b)
		
		var b = HBoxContainer.new()
		add_child(b)
		curr_container = b
		
		#create index
		var c = ind.instantiate()
		index_container.add_child(c)
		c.set_color(cols[i])
		c.set_text(str(fus[i]-20) + " Fu")
