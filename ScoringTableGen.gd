extends RichTextLabel

func _ready():
	clear()
	
	var FU_TO_SHOW = 6
	
	var tex = "[table=%d]" % (FU_TO_SHOW+1)
	
	var c = "[cell]%s[/cell]"
	
	tex += c % "H\\F"
	
	for FU in range(0, (FU_TO_SHOW) * 10, 10):
			tex += c % (FU+20)
	
	for HAN in range(1, 14, 1):
		tex += c % HAN
		
		for FU in range(0, (FU_TO_SHOW) * 10, 10):
			tex += c % str(ScoringInfo._aoten_points_count(FU+20, HAN, 0) * 4)
	
	tex += "[/table]"
	
	append_text(tex)
