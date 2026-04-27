extends Node2D

# --- Exports ---
@export_group("Inputs")
@export var action_left: String = "p1_left"
@export var action_right: String = "p1_right"
@export var action_up: String = "p1_up"
@export var action_down: String = "p1_down"

# --- Nodes ---
@onready var sprite = $Sprite2D

# --- Variables ---
var desired_direction: float = 0.0 
var width: float = 6.0
var height: float = 10.0

# --- Constants ---
var MIN_HEIGHT: float = 3.0
var MAX_HEIGHT: float = 30.0
var STRETCH_SPEED: float = 2.0

func _process(delta: float) -> void:
	# --- Directions ---
	desired_direction = Input.get_axis(action_left, action_right)
	
	# --- Piston Stretch ---
	var target_height = height
	
	if Input.is_action_pressed(action_up):
		target_height = MAX_HEIGHT
	elif Input.is_action_pressed(action_down):
		target_height = MIN_HEIGHT
	
	height = lerp(height, target_height, STRETCH_SPEED * delta)
	
	# --- Process ---
	sprite.scale = Vector2(width, height)
	sprite.position.y = -height / 2.0
