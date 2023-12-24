##  RichTextLabels do not automatically translate themselves,
## this is just simple code to force them to do o
extends RichTextLabel
class_name RTLTranslator

@export var bold = false

func _ready():
	var temp = ("" if !bold else "[b]") + tr(text)
	clear()
	append_text(temp)
