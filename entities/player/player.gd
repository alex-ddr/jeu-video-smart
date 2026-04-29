extends CharacterBody2D

# --- Exports ---
@export_group("Inputs")
@export var action_left: String = "p1_left"
@export var action_right: String = "p1_right"
@export var action_up: String = "p1_up"
@export var action_down: String = "p1_down"
@export var action_launch: String = "p1_launch"
@export var action_jump: String = "p1_jump"

# --------------------------- Onready ---------------------------
@onready var body: Sprite2D = $Body
@onready var collision: CollisionShape2D = $CollisionShape2D

# --------------------------- Signals ---------------------------
signal launch_released(force: float)


# --------------------------- Constants ---------------------------
# Size
const TILE_SIZE = Global.TILE_SIZE

@onready var MIN_HEIGHT: float = 128
@onready var MAX_HEIGHT: float = 512
@onready var MAX_LAUNCH_FORCE: float = TILE_SIZE * 13.33

# Stretch size (up/down) : linear move_toward 
@onready var SIZE_SPEED: float = TILE_SIZE * 1.0

# Launch charge : hard spring
const LAUNCH_CHARGE_STIFFNESS: float = 15.0
const LAUNCH_CHARGE_DAMPING: float = 10.0

# Launch release : fast spring
const LAUNCH_RELEASE_STIFFNESS: float = 700.0
const LAUNCH_RELEASE_DAMPING: float = 20.0

# Jump
@onready var JUMP_VELOCITY: float = -TILE_SIZE * 6.66

@onready var STOP_TOLERANCE: float = TILE_SIZE * 0.015

# --------------------------- Variables ---------------------------
var desired_direction: float = 0.0

@onready var width: float = 256.0
@onready var height: float = 256.0

var height_velocity: float = 0.0

var launch_charge_start_height: float = 0.0
var pending_launch_force: float = 0.0
var is_releasing_launch: bool = false
var release_target_height: float = 0.0

func _ready() -> void:
	collision.shape = collision.shape.duplicate()


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_read_input()
	_update_stretch(delta)
	_compute_launch()
	_sync_collision()
	_sync_visuals()
	move_and_slide()


# --------------------------- Physics ---------------------------
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


# --------------------------- Inputs ---------------------------
func _read_input() -> void:
	desired_direction = Input.get_axis(action_left, action_right)
	if Input.is_action_just_pressed(action_jump) and is_on_floor():
		velocity.y = JUMP_VELOCITY

# --------------------------- Stretch ---------------------------
func _get_size_target() -> float:
	if Input.is_action_pressed(action_up):
		return MAX_HEIGHT
	if Input.is_action_pressed(action_down):
		return MIN_HEIGHT
	return height

func _get_launch_charge_target() -> float:
	if Input.is_action_just_pressed(action_launch):
		launch_charge_start_height = height
	return MIN_HEIGHT

# ça évite de pouvoir faire les deux stretch en même temps
func _get_stretch_target() -> float:
	if is_releasing_launch:
		return release_target_height
	if Input.is_action_pressed(action_launch) and is_on_floor():
		return _get_launch_charge_target()
	return _get_size_target()


func _update_stretch(delta: float) -> void:
	var target = _get_stretch_target()

	if is_releasing_launch:
		var spring_force = (target - height) * LAUNCH_RELEASE_STIFFNESS
		height_velocity += (spring_force - height_velocity * LAUNCH_RELEASE_DAMPING) * delta
		height += height_velocity * delta
		# Pas de clamp ici — on laisse dépasser pour le rebond
		# On clamp seulement en dessous (le piston ne peut pas disparaître)
		height = max(height, MIN_HEIGHT)

	elif Input.is_action_pressed(action_launch) and is_on_floor():
		var spring_force = (target - height) * LAUNCH_CHARGE_STIFFNESS
		height_velocity += (spring_force - height_velocity * LAUNCH_CHARGE_DAMPING) * delta
		height += height_velocity * delta
		height = clamp(height, MIN_HEIGHT, MAX_HEIGHT)

	else:
		height_velocity = 0.0
		height = move_toward(height, target, SIZE_SPEED * delta)
		if abs(height - target) < STOP_TOLERANCE:
			height = target
		height = clamp(height, MIN_HEIGHT, MAX_HEIGHT)


# --------------------------- Launch ---------------------------
func _compute_launch() -> void:
	if Input.is_action_just_released(action_launch) and is_on_floor():
		var margin = TILE_SIZE * 0.003
		var retraction_ratio = clamp(
			inverse_lerp(launch_charge_start_height, MIN_HEIGHT, height + margin),
			0.0, 1.0
		)
		pending_launch_force = retraction_ratio * MAX_LAUNCH_FORCE

		is_releasing_launch = true
		release_target_height = launch_charge_start_height
		emit_signal("launch_released", pending_launch_force)
	else:
		pending_launch_force = 0.0

	var height_diff_tolerance = TILE_SIZE * 0.03
	if is_releasing_launch and abs(height_velocity) < STOP_TOLERANCE and abs(height - release_target_height) < height_diff_tolerance:
		height = release_target_height
		height_velocity = 0.0
		is_releasing_launch = false


# --------------------------- Sync ---------------------------
func _sync_collision() -> void:
	pass
	#var shape = collision.shape as RectangleShape2D
	#if body.texture:
		#var tex_size = body.texture.get_size()
		#shape.size = Vector2(tex_size.x, height)
	#collision.position.y = -height / 2.0
#
#
func _sync_visuals() -> void:
	if body.texture:
		var tex_size = body.texture.get_size()
		body.scale.y = height / tex_size.y
	body.position.y = -height / 2.0
