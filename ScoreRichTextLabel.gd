# text highlighter.
extends RTLTranslator

func _ready():
	super._ready()
	
	var t = text
	t = t.replace("Fu", "[color=%s]Fu[/color]" % COL.LBLUE)
	t = t.replace("Han", "[color=%s]Han[/color]" % COL.LRED)
	
	clear()
	append_text(t)
