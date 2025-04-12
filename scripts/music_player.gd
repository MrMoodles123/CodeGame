class_name MusicPlayer extends Node

@onready var audio_stream_player = $AudioStreamPlayer

var tracks = [preload("res://Audio/Music/Stardew Valley OST - Dance Of The Moonlight Jellies.mp3"),preload("res://Audio/Music/Stardew Valley OST - Fall (The Smell of Mushroom).mp3"),preload("res://Audio/Music/Stardew Valley OST - Land Of Green And Gold (Leah's Theme).mp3"),preload("res://Audio/Music/Stardew Valley OST - Spring (Wild Horseradish Jam).mp3")]
var curr_track: int = 0
var num_tracks = tracks.size()

func _ready():
	randomize()
	tracks.shuffle()
	start_music()

func start_music():
	audio_stream_player.volume_db = -10
	audio_stream_player.stream = tracks[curr_track]
	audio_stream_player.play()

func _on_audio_stream_player_finished():
	curr_track += 1
	if curr_track == num_tracks:
		curr_track = 0
	audio_stream_player.stream = tracks[curr_track]
	audio_stream_player.play()
