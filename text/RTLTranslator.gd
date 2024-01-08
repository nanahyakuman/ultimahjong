##  RichTextLabels do not automatically translate themselves,
## this is just simple code to force them to do o
extends RichTextLabel
class_name RTLTranslator

@export var bold = false

var key = ""

# onm startup read in the key
func _ready():
	key = text
	generate()
	
	LocaleChangedSignaller.connect("locale_changed", generate)

func generate():
	var temp = ("" if !bold else "[b]") + tr(key)
	clear()
	append_text(temp)
