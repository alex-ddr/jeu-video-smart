@tool
extends Node2D

@export var white_height: float = 87.0 :
	set(value):
		white_height = value
		_update()

@export var key: String = "z" :
	set(value):
		key = value
		_update()

func _ready() -> void:
	_update()

func _update() -> void:
	# Texture
	var path = "res://assets/input_keys/keyboard_" + key + "_outline.png"
	if ResourceLoader.exists(path):
		$Key.texture = load(path)
	
	# Height + centrage du ColorRect
	var rect = $ColorRect
	rect.size.y = white_height
	rect.position.y = -white_height / 2.0  # centre verticalement
	rect.position.x = -rect.size.x / 2.0   # centre horizontalement
