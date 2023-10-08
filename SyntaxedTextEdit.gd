extends TextEdit

const TILES = ["terminal", "terminals"]

const col = Color.WHITE

func _ready():
	syntax_highlighter.set_color_regions({})
	syntax_highlighter.function_color = col
	syntax_highlighter.member_variable_color = col
	syntax_highlighter.number_color = col
	syntax_highlighter.symbol_color = col
	
	for t in TILES:
		syntax_highlighter.add_keyword_color(t, Color.ROYAL_BLUE)
