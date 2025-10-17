extends Node

@export var audio_set: AudioSet
var boss = false


func _ready():
	if boss:
		audio_set = load("res://assets/music/boss.tres")
	else:
		audio_set = load("res://assets/music/chill.tres")


func stop_music():
	if audio_set and audio_set.end != "":
		$AudioPlayer.loop = false
		$AudioPlayer.stream = load(audio_set.end)
		$AudioPlayer.play()

		await $AudioPlayer.finished
		$AudioPlayer.stop()


func start_music():
	if audio_set and audio_set.start != "":
		$AudioPlayer.stream = load(audio_set.start)
		$AudioPlayer.play()
		await $AudioPlayer.finished
	if audio_set and audio_set.loop != "":
		$AudioPlayer.stream = load(audio_set.loop)
		$AudioPlayer.loop = true
		$AudioPlayer.play()
