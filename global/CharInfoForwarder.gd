##  literally just holds onto the selected charinfo so
## we can change scenes without losing it
##  also holds whether or not to call "load"
extends Node

var ci: CharacterInfo = CharacterInfo.new()
var load = false

func _ready():
	ci.set_type(CharacterInfo.TYPES.REGULAR)
