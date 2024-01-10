extends Button

@export var val = "en"


#func _ready():
#	if val.substr(0,2) == TranslationServer.get_locale().substr(0,2):
#		button_pressed = true

func _pressed():
	TranslationServer.set_locale(val)
	
	for c in get_parent().get_children():
		if c == self:
			continue
		c.button_pressed = false
	
	LocaleChangedSignaller.emit_signal("locale_changed")
	
	release_focus()
