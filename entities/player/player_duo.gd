extends Node2D

# --------------------------- Constants ---------------------------
const MAX_SPEED: float = 50.0
const MIN_SPEED: float = 10.0
const ACCELERATION: float = 200.0
const FRICTION: float = 200.0
const WEIGHT_CURVE: float = 2.0
const VELOCITY_THRESHOLD: float = 0.01
const JUMP_HORIZONTAL_BIAS: float = 0.3

# --------------------------- Onready ---------------------------
@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var line = $Line2D


func _ready() -> void:
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	_apply_horizontal(delta)
	_update_rope()

# --------------------------- Horizontal movement ---------------------------
func _get_player_speed(player) -> float:
	var ratio = inverse_lerp(player.MIN_HEIGHT, player.MAX_HEIGHT, player.height)
	var penalty = pow(ratio, WEIGHT_CURVE)
	return lerp(MAX_SPEED, MIN_SPEED, penalty)


func _apply_horizontal(delta: float) -> void:
	var target_speed = p1.desired_direction * _get_player_speed(p1) + p2.desired_direction * _get_player_speed(p2)

	if abs(target_speed) > VELOCITY_THRESHOLD:
		p1.velocity.x = move_toward(p1.velocity.x, target_speed, ACCELERATION * delta)
	else:
		p1.velocity.x = move_toward(p1.velocity.x, 0.0, FRICTION * delta)
	p2.velocity.x = p1.velocity.x


# --------------------------- Rope ---------------------------
func _update_rope() -> void:
	line.set_point_position(0, to_local(p1.global_position) + Vector2(0, -p1.height))
	line.set_point_position(1, to_local(p2.global_position) + Vector2(0, -p2.height))
