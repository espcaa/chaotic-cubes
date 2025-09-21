extends Node2D


signal roll_finished

@export var dice_frames: SpriteFrames = load("res://assets/dice_normal.tres")
@export var faces: Array = [0, 1, 2, 3, 4, 5]

var value: Array = []
var playing = false


func roll():
	pass


func _ready() -> void:
	$AnimatedSprite2D.sprite_frames = dice_frames
