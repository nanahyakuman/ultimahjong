##  literally just holds onto the selected charinfo so
## we can change scenes without losing it
extends Node

var ci: CharacterInfo = CharacterInfo.new()

func _ready():
	ci.set_type(CharacterInfo.TYPES.REGULAR)
