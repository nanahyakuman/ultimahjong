extends RichTextLabel

var cols = [COL.LBLUE, COL.LGREEN, COL.LRED, COL.YELLOW, COL.TAN]
var BASE = 3
var OFFSET = 1

@export var center = true

func set_text_colorized(tex: String):
	var length = tex.length()
	var tex_out = ""
	
	for i in cols.size():
		var digit = (i+1)*(BASE)+OFFSET
		if length >= digit:
			tex_out = tex.substr(0,length-digit) + ("[color=%s]" % cols[i]) + tex.substr(length-digit,1) + "[/color]" + tex.substr(length-digit+1)
		tex = tex_out
	
	while tex_out.length() < 4:
		tex_out = "0" + tex_out
	
	clear()
	append_text(("[center]" if center else "") + "[b]" + tex_out)
