extends CharacterBody2D

# --- Exports ---
@export_group("Inputs")
@export var action_left: String = "p1_left"
@export var action_right: String = "p1_right"
@export var action_up: String = "p1_up"
@export var action_down: String = "p1_down"
@export var action_jump: String = "p1_jump"
@export var action_big_jump: String = "p1_big_jump"

# --------------------------- Onready ---------------------------
@onready var body: Polygon2D = $Body
@onready var collision: CollisionShape2D = $CollisionShape2D

# --------------------------- Signals ---------------------------
signal jump_released(force: float)


# --------------------------- Constants ---------------------------
const SCALE_UNIT: float = 4.0

const MIN_HEIGHT: float = 30.0
const MAX_HEIGHT: float = 180.0
const MAX_JUMP_FORCE: float = 800.0

const SIZE_SPEED: float = 300.0

const JUMP_CHARGE_STIFFNESS: float = 15.0
const JUMP_CHARGE_DAMPING: float = 10.0

const JUMP_RELEASE_STIFFNESS: float = 700.0
const JUMP_RELEASE_DAMPING: float = 20.0

# --------------------------- Variables ---------------------------
var desired_direction: float = 0.0

var width: float = 25.0
var height: float = 100.0
var height_velocity: float = 0.0

var jump_charge_start_height: float = 0.0
var pending_jump_force: float = 0.0
var is_releasing_jump: bool = false
var release_target_height: float = 0.0





	
	


func _ready() -> void:
	collision.shape = collision.shape.duplicate()


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_read_input()
	_update_stretch(delta)
	_compute_jump()
	_sync_collision()
	_sync_visuals()
	move_and_slide()
	#jump()
	


# --------------------------- Physics ---------------------------
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


# --------------------------- Inputs ---------------------------
func _read_input() -> void:
	desired_direction = Input.get_axis(action_left, action_right)
	
	
# --------------------------- Stretch ---------------------------
func _get_size_target() -> float:
	if Input.is_action_pressed(action_up):
		return MAX_HEIGHT
	if Input.is_action_pressed(action_down):
		return MIN_HEIGHT
	return height

func _get_jump_charge_target() -> float:
	if Input.is_action_just_pressed(action_jump):
		jump_charge_start_height = height
	return MIN_HEIGHT

# ça évite de pouvoir faire les deux stretch en même temps
func _get_stretch_target() -> float:
	if is_releasing_jump:
		return release_target_height
	if Input.is_action_pressed(action_jump) and is_on_floor():
		return _get_jump_charge_target()
	return _get_size_target()


func _update_stretch(delta: float) -> void:
	var target = _get_stretch_target()

	if is_releasing_jump:
		var spring_force = (target - height) * JUMP_RELEASE_STIFFNESS
		height_velocity += (spring_force - height_velocity * JUMP_RELEASE_DAMPING) * delta
		height += height_velocity * delta
		# Pas de clamp ici — on laisse dépasser pour le rebond
		# On clamp seulement en dessous (le piston ne peut pas disparaître)
		height = max(height, MIN_HEIGHT)

	elif Input.is_action_pressed(action_jump) and is_on_floor():
		var spring_force = (target - height) * JUMP_CHARGE_STIFFNESS
		height_velocity += (spring_force - height_velocity * JUMP_CHARGE_DAMPING) * delta
		height += height_velocity * delta
		height = clamp(height, MIN_HEIGHT, MAX_HEIGHT)

	else:
		height_velocity = 0.0
		height = move_toward(height, target, SIZE_SPEED * delta)
		if abs(height - target) < 0.5:
			height = target
		height = clamp(height, MIN_HEIGHT, MAX_HEIGHT)


# --------------------------- Jump ---------------------------
func _compute_jump() -> void:
	if Input.is_action_just_released(action_jump) and is_on_floor():
		var retraction_ratio = clamp(
			inverse_lerp(jump_charge_start_height, MIN_HEIGHT, height + 0.1),
			0.0, 1.0
		)
		pending_jump_force = retraction_ratio * MAX_JUMP_FORCE

		is_releasing_jump = true
		release_target_height = jump_charge_start_height
		emit_signal("jump_released", pending_jump_force)
	else:
		pending_jump_force = 0.0

	if is_releasing_jump and abs(height_velocity) < 0.5 and abs(height - release_target_height) < 1.0:
		height = release_target_height
		height_velocity = 0.0
		is_releasing_jump = false


# --------------------------- Sync ---------------------------
func _sync_collision() -> void:
	var shape = collision.shape as RectangleShape2D
	shape.size = Vector2(width, height)
	collision.position.y = -height / 2.0


func _sync_visuals() -> void:
	var hw = width / 2.0
	body.polygon = PackedVector2Array([
		Vector2(-hw, 0.0),
		Vector2( hw, 0.0),
		Vector2( hw, -height),
		Vector2(-hw, -height),
	])
