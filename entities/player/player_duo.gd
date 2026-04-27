extends CharacterBody2D

# --- Constants ---
var MAX_SPEED: float = 50.0  
var MIN_SPEED: float = 10.0  
var ACCELERATION: float = 200.0
var FRICTION: float = 200.0
var WEIGHT_CURVE: float = 2.0

# --- Nodes ---
@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var p1_collision = $p1_collision
@onready var p2_collision = $p2_collision
@onready var line = $Line2D

func _ready() -> void:	
	# --- Collision ---
	p1_collision.shape = p1_collision.shape.duplicate()
	p2_collision.shape = p2_collision.shape.duplicate()
	
	# --- Line Setup ---
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	# --- Gravity ---
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# --- Input Resolution ---
	
	var stretch_ratio_p1 = inverse_lerp(p1.MIN_HEIGHT, p1.MAX_HEIGHT, p1.height)
	var stretch_ratio_p2 = inverse_lerp(p2.MIN_HEIGHT, p2.MAX_HEIGHT, p2.height)

	var weight_penalty_p1 = pow(stretch_ratio_p1, WEIGHT_CURVE)
	var weight_penalty_p2 = pow(stretch_ratio_p2, WEIGHT_CURVE)

	var current_speed_p1 = lerp(MAX_SPEED, MIN_SPEED, weight_penalty_p1)
	var current_speed_p2 = lerp(MAX_SPEED, MIN_SPEED, weight_penalty_p2)

	var pulling_force_p1 = p1.desired_direction * current_speed_p1
	var pulling_force_p2 = p2.desired_direction * current_speed_p2

	var target_speed = pulling_force_p1 + pulling_force_p2
	
	# --- Movements ---
	if target_speed != 0:
		velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# --- Collision ---
	p1_collision.shape.size = Vector2(p1.width, p1.height)
	p2_collision.shape.size = Vector2(p2.width, p2.height)
	
	p1_collision.position.y = -p1.height / 2.0
	p2_collision.position.y = -p2.height / 2.0
	
	# --- Line Update ---
	var top_p1 = Vector2(p1_collision.position.x, -p1.height)
	var top_p2 = Vector2(p2_collision.position.x, -p2.height)
	
	line.set_point_position(0, top_p1)
	line.set_point_position(1, top_p2)
	
	move_and_slide()
