extends Node

@onready var music = $AudioStreamPlayer
var current_track: AudioStream = null

@export var audio_library: AudioLibrary 


func play_music(track: AudioStream):
	if current_track == track and music.playing:
		return

	current_track = track
	music.stream = track
	music.play()

func stop_music():
	music.stop()

func pause_music():
	music.stream_paused = true

func resume_music():
	music.stream_paused = false

#ATAJOS
func play_menu():
	play_music(audio_library.musica_menu)

func play_battle():
	play_music(audio_library.musica_batalla)
