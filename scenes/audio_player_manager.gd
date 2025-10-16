extends Node

@export var audio_set: AudioSet
var boss = false


func _ready():
	if boss:
		audio_set = load("res://assets/music/boss.tres")
	else:
		audio_set = load("res://assets/music/chill.tres")


func start_music():
	if audio_set and audio_set.start != "":
		AudioManager.boss = boss
		self.stream = load(audio_set.start)

		play()
		await player.finished
		if audio_set.loop != "":
			player.stream = load(audio_set.loop)
			player.loop = true
			player.play()
	else:
		player.loop = false


func stop_music():
	if audio_set and audio_set.end != "":
		$AudioPlayerManager.loop = false
		$AudioPlayerManager.stream = load(audio_set.end)
		$AudioPlayerManager.play()
		await $AudioPlayerManager.finished
		self.stram = load(audio_set.start)
	else:
		$AudioPlayerManager.stop()
