extends Node2D

# --------------------------- Constants ---------------------------
const MAX_SPEED: float = 700.0
const MIN_SPEED: float = 550.0
const ACCELERATION: float = 700.0
const FRICTION: float = 600.0
const WEIGHT_CURVE: float = 2.0
const VELOCITY_THRESHOLD: float = 0.01

const SOLO_JUMP_FORCE := -400.0
const DUO_JUMP_FORCE := -900.0
const JUMP_HORIZONTAL_BOOST := 400.0

const DUO_AIR_JUMP_FORCE := -800.0
const DUO_AIR_HORIZONTAL_BOOST := 450.0
const AIR_JUMP_SYNC_WINDOW := 0.4

var rope_length: float = 250.0
var duo_jump_used: bool = false
var p1_has_jumped: bool = false
var p2_has_jumped: bool = false

var duo_air_jump_used: bool = false
var p1_air_jump_buffer: float = 0.0
var p2_air_jump_buffer: float = 0.0

# --------------------------- Onready ---------------------------
@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var line = $Line2D
@onready var bar_body = $StaticBody2D
@onready var rope_collision: CollisionShape2D = $StaticBody2D/rope_collision
@onready var camera: Camera2D = $Camera2D

# --------------------------- Ready ---------------------------
func _ready() -> void:
	camera.enabled = true

	var shape := RectangleShape2D.new()
	rope_collision.shape = shape

	var mat := PhysicsMaterial.new()
	mat.bounce = 0.0
	mat.friction = 0.0
	bar_body.physics_material_override = mat

	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)

# --------------------------- Main loop ---------------------------
func _physics_process(delta: float) -> void:
	_apply_horizontal(delta)
	_handle_duo_jump(delta)
	_enforce_rope_distance()
	_enforce_platform_support()
	_update_rope()
	_update_camera()

# --------------------------- Camera ---------------------------
func _update_camera() -> void:
	var target: Vector2 = (p1.global_position + p2.global_position) * 0.5
	camera.global_position = camera.global_position.lerp(target, 0.12)

# --------------------------- Rope distance ---------------------------
func _enforce_rope_distance() -> void:
	var diff: Vector2 = p2.global_position - p1.global_position
	var current_distance := diff.length()

	if current_distance == 0:
		return

	var direction := diff / current_distance
	var error := current_distance - rope_length
	var correction := direction * (error * 0.5)

	p1.global_position.x += correction.x
	p2.global_position.x -= correction.x

# --------------------------- Horizontal ---------------------------
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

# --------------------------- Rope (PHYSIQUE) ---------------------------
func _update_rope() -> void:
	var pos_a = to_local(p1.global_position) + Vector2(-25, -p1.height)
	var pos_b = to_local(p2.global_position) + Vector2(25, -p2.height)

	var middle: Vector2 = (pos_a + pos_b) * 0.5
	var diff: Vector2 = pos_b - pos_a
	var length: float = diff.length()
	var angle: float = diff.angle()

	# VISUEL
	line.set_point_position(0, pos_a)
	line.set_point_position(1, pos_b)

	# COLLISION PHYSIQUE (IMPORTANT)
	rope_collision.position = middle
	rope_collision.rotation = angle

	var rect := rope_collision.shape as RectangleShape2D
	rect.size = Vector2(length, 20.0) # épaisseur réelle

# --------------------------- Jump ---------------------------
func _handle_duo_jump(delta: float) -> void:
	var p1_pressed: bool = Input.is_action_just_pressed(p1.action_big_jump)
	var p2_pressed: bool = Input.is_action_just_pressed(p2.action_big_jump)

	if p1.is_on_floor() and p2.is_on_floor():
		duo_jump_used = false
		duo_air_jump_used = false
		p1_has_jumped = false
		p2_has_jumped = false
		p1_air_jump_buffer = 0.0
		p2_air_jump_buffer = 0.0

	p1_air_jump_buffer = max(0.0, p1_air_jump_buffer - delta)
	p2_air_jump_buffer = max(0.0, p2_air_jump_buffer - delta)

	if not p1.is_on_floor() and not p2.is_on_floor():
		if p1_pressed:
			p1_air_jump_buffer = AIR_JUMP_SYNC_WINDOW
		if p2_pressed:
			p2_air_jump_buffer = AIR_JUMP_SYNC_WINDOW

		if not duo_air_jump_used and p1_air_jump_buffer > 0.0 and p2_air_jump_buffer > 0.0:
			_apply_duo_air_jump()
			duo_air_jump_used = true
			p1_air_jump_buffer = 0.0
			p2_air_jump_buffer = 0.0
			return

	if p1_pressed and p1.is_on_floor():
		p1.velocity.y = SOLO_JUMP_FORCE
		p1_has_jumped = true

	if p2_pressed and p2.is_on_floor():
		p2.velocity.y = SOLO_JUMP_FORCE
		p2_has_jumped = true

	if not duo_jump_used and p1_has_jumped and p2_has_jumped:
		_apply_duo_jump()
		duo_jump_used = true

func _apply_duo_jump() -> void:
	p1.velocity.y = DUO_JUMP_FORCE
	p2.velocity.y = DUO_JUMP_FORCE

	var direction: float = p1.desired_direction + p2.desired_direction
	if abs(direction) > 0.1:
		var boost: float = sign(direction) * JUMP_HORIZONTAL_BOOST
		p1.velocity.x += boost
		p2.velocity.x += boost


func _apply_duo_air_jump() -> void:
	p1.velocity.y = DUO_AIR_JUMP_FORCE
	p2.velocity.y = DUO_AIR_JUMP_FORCE

	var direction: float = p1.desired_direction + p2.desired_direction

	if abs(direction) > 0.1:
		var boost: float = sign(direction) * DUO_AIR_HORIZONTAL_BOOST
		p1.velocity.x += boost
		p2.velocity.x += boost


func _enforce_platform_support() -> void:
	if p1.is_on_floor() and not p2.is_on_floor():
		if p2.global_position.y > p1.global_position.y:
			p2.global_position.y = p1.global_position.y
			p2.velocity.y = min(p2.velocity.y, 0.0)

	elif p2.is_on_floor() and not p1.is_on_floor():
		if p1.global_position.y > p2.global_position.y:
			p1.global_position.y = p2.global_position.y
			p1.velocity.y = min(p1.velocity.y, 0.0)
