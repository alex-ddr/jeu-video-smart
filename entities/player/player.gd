extends CharacterBody2D

# --- Exports ---
@export_group("Inputs")
@export var action_left: String = "p1_left"
@export var action_right: String = "p1_right"
@export var action_up: String = "p1_up"
@export var action_down: String = "p1_down"
@export var action_launch: String = "p1_launch"
@export var action_jump: String = "p1_jump"

# --------------------------- Signals ---------------------------
signal launch_released(force: float)

# --------------------------- Constants ---------------------------
const TILE_SIZE = Global.TILE_SIZE
const GRAVITY = Global.GRAVITY

# Spring: Launch charge (Hard)
const LAUNCH_CHARGE_STIFFNESS: float = 15.0
const LAUNCH_CHARGE_DAMPING: float = 10.0

# Spring: Launch release (Fast)
const LAUNCH_RELEASE_STIFFNESS: float = 700.0
const LAUNCH_RELEASE_DAMPING: float = 20.0

# --------------------------- Parameters (Onready Config) -------
@onready var MIN_HEIGHT: float = 16.0
@onready var MAX_HEIGHT: float = 200.0
@onready var SIZE_SPEED: float = TILE_SIZE * 1.5
@onready var MAX_LAUNCH_FORCE: float = TILE_SIZE * 13.33
@onready var JUMP_VELOCITY: float = -TILE_SIZE * 10.0
@onready var STOP_TOLERANCE: float = TILE_SIZE * 0.015

const FALL_GRAVITY_MULTIPLIER: float = 1.8 # Le perso tombe presque 2x plus vite qu'il ne monte
const JUMP_CUT_MULTIPLIER: float = 0.5     # Divise la vitesse par 2 si on lâche le bouton tôt
const COYOTE_TIME: float = 0.1             # Temps de grâce en quittant un rebord (100ms)
const JUMP_BUFFER_TIME: float = 0.1        # Mémorise l'appui sur saut avant de toucher le sol

const BODY_HEIGHT_OFFSET: float = 86.0
const BODY_HEIGHT_DEFAULT: float = 42.0
const ROPE_HOOK_OFFSET: float = 60.0
# --------------------------- State Variables ---------------------
# Movement
var desired_direction: float = 0.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# Height / Stretch
@onready var height: float = Global.DEFAULT_HEIGHT
@onready var last_height: float = height
var height_velocity: float = 0.0


# Launch
var launch_charge_start_height: float = 0.0
var pending_launch_force: float = 0.0
var is_releasing_launch: bool = false
var release_target_height: float = 0.0

# --------------------------- Nodes -------------------------------
@onready var body: Sprite2D = $Body
@onready var head: Sprite2D = $Head_p1 if action_jump == "p1_jump" else $Head_p2
@onready var feet: AnimatedSprite2D = $AnimatedFeet
@onready var collision: CollisionShape2D = $CollisionShape2D



func _ready() -> void:
	collision.shape = collision.shape.duplicate()
	head.visible = true
	pass

	
func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_read_input(delta)
	_update_stretch(delta)
	_compute_launch()
	_sync_collision()
	_update_animation()
	move_and_slide()

func _process(delta: float) -> void:
	_sync_visuals()

# --------------------------- Physics ---------------------------
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		var current_gravity = GRAVITY
		
		# Si on est en train de retomber, on applique le multiplicateur pour une chute plus lourde
		if velocity.y > 0:
			current_gravity *= FALL_GRAVITY_MULTIPLIER
			
		velocity += current_gravity * delta


# --------------------------- Inputs ---------------------------
func _read_input(delta: float) -> void:
	desired_direction = Input.get_axis(action_left, action_right)
	
	# 1. Gestion des Timers (Coyote & Buffer)
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
		
	if Input.is_action_just_pressed(action_jump):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	# 2. Exécution du Saut
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		var height_ratio = inverse_lerp(MIN_HEIGHT, MAX_HEIGHT, height)
		velocity.y = lerp(JUMP_VELOCITY, JUMP_VELOCITY * 0.4, height_ratio)
		jump_buffer_timer = 0.0 # Reset pour éviter le double-saut
		coyote_timer = 0.0      # Reset pour éviter un autre saut en l'air

	# 3. Hauteur de saut variable (Si le joueur lâche le bouton pendant l'ascension)
	if Input.is_action_just_released(action_jump) and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

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

func _sync_visuals() -> void:
	body.scale.y = height / BODY_HEIGHT_DEFAULT
	head.position.y = -height
	last_height = height
	
func _sync_collision() -> void:
	var shape = collision.shape as RectangleShape2D
	shape.size = Vector2(64.0, height+BODY_HEIGHT_OFFSET)
	collision.position.y = -(height+BODY_HEIGHT_OFFSET) / 2.0
	
	if desired_direction != 0:
		var flipped = desired_direction < 0
		body.flip_h = flipped
		head.flip_h = flipped
		feet.flip_h = flipped
		
func _update_animation() -> void:
	if not is_on_floor():
		if feet.animation != "jump":
			feet.play("jump")
		elif not feet.is_playing():
			pass
	elif abs(desired_direction) > 0.01:
		feet.play("walk")
	else:
		feet.play("idle")
