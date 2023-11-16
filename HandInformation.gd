##  simple wrapper for hand information, used in scoring
extends Resource
class_name HandInformation

var hand: Array = []
var tsumo: MTile = null
var already_made_groupings: Array = [] # of `Groupings`
var most_recent_discard: MTile = null # ignored if tsumo is defined
