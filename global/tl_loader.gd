##  loads a csv file as a translation from the user folder.
## should make community translation possible.
extends Node

var filename = "user://tr.csv"

#  this loader assumes that the first row is the source string,
# and NOTABLY that the second row is discardable!

func _ready():
	var file = FileAccess.open(filename, FileAccess.READ)
	
	#  if there's no custom file just load the existing ones. disgustingly hardcoded
	# but not gonna be the final solution anyway
	if !file:
		TranslationServer.add_translation(load("res://text/MAHJONG_TRANSLATIONS.en.translation"))
		TranslationServer.add_translation(load("res://text/MAHJONG_TRANSLATIONS.ja.translation"))
		TranslationServer.set_locale(TranslationServer.get_locale())
		return
	
	# read from the file
	var csv_line = file.get_csv_line()
	
	# init translations
	var translations = []
	for i in range(2, csv_line.size()):
		var t = Translation.new()
		t.locale = csv_line[i]
		translations.append(t)
	
	# read all translations
	while file.get_position() < file.get_length():
		csv_line = file.get_csv_line()
		for i in range(2, csv_line.size()):
			translations[i-2].add_message(csv_line[0], csv_line[i])
	
	# add new translations and refresh
	TranslationServer.clear()
	for t in translations:
		TranslationServer.add_translation(t)
	TranslationServer.set_locale(TranslationServer.get_locale())
