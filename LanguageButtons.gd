##  import community languges
extends OneOfManySelectorSaver

# import external translations as buttons
func _ready():
	for locale in TranslationServer.get_loaded_locales():
		if ["en", "ja"].has(locale):
			continue
		else:
			var b = get_child(0).duplicate()
			b.val = locale
			b.text = locale
			add_child(b)
