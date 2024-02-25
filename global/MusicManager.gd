##  implements different 'tracks' so we can set one as active and iterate through its
## segments. this should be much simpler than the old one, msot tracks should only need
## a base form, riichi/tenpai form, shop form, and transitions.
extends Node
@onready var audio_stream_player = $AudioStreamPlayer
@onready var sfx_audio_stream_player = $SFXAudioStreamPlayer

var FILE_PATHS = ["res://audio/music/1/"]
var EXTENSION = ".mp3"
var index = 9999

enum {BASE, TENPAI, SHOP, HAN, WIN}
var data = []

const SEMITONE_RATIO = pow(2.0,1.0/12.0)

func queue_next_song():
	index += 1
	
	# shuffle, ensure no repeats
	if index >= FILE_PATHS.size():
		var curr = FILE_PATHS[-1]
		index = 0
		if FILE_PATHS.size() > 1:
			while curr == FILE_PATHS[index]:
				FILE_PATHS.shuffle()
	
	data.clear()
	data.append(load(FILE_PATHS[index]+"base"+EXTENSION))
	data.append(load(FILE_PATHS[index]+"tenpai"+EXTENSION))
	data.append(load(FILE_PATHS[index]+"shop"+EXTENSION))
	data.append(load(FILE_PATHS[index]+"han"+EXTENSION))
	data.append(load(FILE_PATHS[index]+"win"+EXTENSION))

func start_round():
	audio_stream_player.stop()
	
	try_start()
	audio_stream_player.stream = data[BASE]
	audio_stream_player.play()

func start_tenpai():
	audio_stream_player.stop()
	
	try_start()
	audio_stream_player.stream = data[TENPAI]
	await get_tree().create_timer(0.2).timeout
	audio_stream_player.play()

func start_scoring():
	audio_stream_player.stop()
	
	sfx_audio_stream_player.pitch_scale = 1.0 / SEMITONE_RATIO

# pitches up every time
func play_han():
	sfx_audio_stream_player.stream = data[HAN]
	sfx_audio_stream_player.pitch_scale *= SEMITONE_RATIO
	
	sfx_audio_stream_player.play()

func start_win():
	audio_stream_player.stop()
	
	try_start()
	audio_stream_player.stream = data[WIN]
	audio_stream_player.play()
	


func start_shop():
	audio_stream_player.stop()
	
	try_start()
	audio_stream_player.stream = data[SHOP]
	await get_tree().create_timer(0.2).timeout
	audio_stream_player.play()


func stop_music():
	audio_stream_player.stop()


# start the manager if there's no song queued but we ask for one anyway
func try_start():
	if data.size() == 0:
		queue_next_song()
