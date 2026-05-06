extends CharacterBody2D

# --- Exports ---
@export_group("Inputs")
@export var action_left: String = "p1_left"
@export var action_right: String = "p1_right"
@export var action_up: String = "p1_up"
@export var action_down: String = "p1_down"
@export var action_launch: String = "p1_launch"
@export var action_jump: String = "p1_jump"

var input_enabled: bool = true

# --------------------------- Signals ---------------------------
signal launch_released(force: float)

# --------------------------- Constants ---------------------------
const TILE_SIZE = Global.TILE_SIZE
const GRAVITY = Global.GRAVITY

const LAUNCH_CHARGE_STIFFNESS: float = 15.0
const LAUNCH_CHARGE_DAMPING: float = 10.0
const LAUNCH_RELEASE_STIFFNESS: float = 700.0
const LAUNCH_RELEASE_DAMPING: float = 20.0

# --------------------------- Parameters ---------------------------
@onready var MIN_HEIGHT: float = 16.0
@onready var MAX_HEIGHT: float = 200.0
@onready var SIZE_SPEED: float = TILE_SIZE * 1.5
@onready var MAX_LAUNCH_FORCE: float = TILE_SIZE * 13.33
@onready var JUMP_VELOCITY: float = -TILE_SIZE * 12.0
@onready var STOP_TOLERANCE: float = TILE_SIZE * 0.015

const FALL_GRAVITY_MULTIPLIER: float = 1.8
const JUMP_CUT_MULTIPLIER: float = 0.25
const COYOTE_TIME: float = 0.2
const JUMP_BUFFER_TIME: float = 0.1

const BODY_HEIGHT_OFFSET: float = 86.0
const BODY_HEIGHT_DEFAULT: float = 42.0
const ROPE_HOOK_OFFSET: float = 60.0
const PUSH_FORCE: float = 900.0

# --------------------------- State Variables ---------------------------
var desired_direction: float = 0.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_invincible: bool = false

@onready var height: float = Global.DEFAULT_HEIGHT
@onready var last_height: float = height
var height_velocity: float = 0.0

var launch_charge_start_height: float = 0.0
var pending_launch_force: float = 0.0
var is_releasing_launch: bool = false
var release_target_height: float = 0.0
var _launch_charge_ratio: float = 0.0

# --------------------------- Nodes ---------------------------
@onready var body: Sprite2D = $Body
@onready var head: Sprite2D = $Head_p1 if action_jump == "p1_jump" else $Head_p2
@onready var feet: AnimatedSprite2D = $AnimatedFeet
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var bounce_sound : AudioStreamPlayer = $BounceSound
@onready var light_occluder_2d: LightOccluder2D = $LightOccluder2D
@onready var polygon_2d: Polygon2D = $Polygon2D

@onready var stretch_sound: AudioStreamPlayer = $StretchSound
@onready var jump_sound: AudioStreamPlayer = $JumpSound

var god_mode: bool = false
var _saved_collision_mask: int = 0
var is_on_ice: bool = false

# --------------------------- Footsteps ---------------------------
@export var footstep_path: String = "res://assets/sounds/footstep0%s.ogg"
@export var footstep_interval_normal: float = 0.1
@export var footstep_interval_start: float = 0.3

var _footstep_timer: float = 0.0
var _walk_time: float = 0.0
var _footstep_sounds: Array = []

@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer


func _ready() -> void:
	collision.shape = collision.shape.duplicate()
	head.visible = true
	_saved_collision_mask = collision_mask
	for i in range(10):
		_footstep_sounds.append(load(footstep_path % str(i)))
	
	jump_sound.volume_db = -10
	footstep_player.volume_db = -20
	stretch_sound.volume_db = 0
	bounce_sound.volume_db = 0

# --------------------------- God Mode ---------------------------
func _input(event: InputEvent) -> void:
	if  (event is InputEventKey and event.keycode == KEY_Y and event.pressed and not event.echo):
		god_mode = !god_mode
		if god_mode:
			_saved_collision_mask = collision_mask
			collision_mask = 0
		else:
			collision_mask = _saved_collision_mask


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_read_input(delta)
	_update_stretch(delta)
	_update_stretch_sound()
	_compute_launch()
	_sync_collision()
	_update_animation()
	move_and_slide()
	_push_rigidbodies()
	_detect_ice()


func _process(delta: float) -> void:
	_sync_visuals()
	_update_footsteps(delta)


# --------------------------- Physics ---------------------------
func _apply_gravity(delta: float) -> void:
	if god_mode:
		velocity.y = Input.get_axis(action_up, action_down) * TILE_SIZE * 8.0
		velocity.x = desired_direction * TILE_SIZE * 8.0
		return
	if not is_on_floor():
		var current_gravity = GRAVITY
		if velocity.y > 0:
			current_gravity *= FALL_GRAVITY_MULTIPLIER
		velocity += current_gravity * delta


# --------------------------- Inputs ---------------------------
func _read_input(delta: float) -> void:
	if not input_enabled:
		desired_direction = 0.0
		velocity.x = move_toward(velocity.x, 0, TILE_SIZE * 40 * delta)
		return

	desired_direction = Input.get_axis(action_left, action_right)

	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed(action_jump):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		var height_ratio = inverse_lerp(MIN_HEIGHT, MAX_HEIGHT, height)
		velocity.y = lerp(JUMP_VELOCITY, JUMP_VELOCITY * 0.4, height_ratio)
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		jump_sound.play_random(0.1)

	if Input.is_action_just_released(action_jump) and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER


# --------------------------- Health & Death ---------------------------
func lose_life() -> void:
	if is_invincible:
		return
		
	# On ne retire une vie QUE si on a dépassé le checkpoint de départ (ID 0)
	if Global.current_checkpoint_id > 0:
		Global.current_lives -= 1
		Global.lives_changed.emit()
		print("Vie perdue ! Nouveau total : ", Global.current_lives)
	else:
		print("Respawn au checkpoint 0 : aucune vie perdue.")
	
	# Vérification du Game Over
	if Global.current_lives <= 0:
		Global.current_lives = Global.max_lives
		Global.current_checkpoint_id = 0 # Sécurité : reset en cas de retour forcé au menu
		GameManager.start_game()
	else:
		# Procédure de respawn classique
		velocity = Vector2.ZERO
		height_velocity = 0.0
		is_invincible = true

		var level = get_tree().current_scene
		if level.has_method("_spawn_at_checkpoint"):
			level._spawn_at_checkpoint()
		else:
			print("Attention: La scène actuelle n'a pas de méthode '_spawn_at_checkpoint'")
			
		# Petit délai d'invincibilité (1 seconde) pour éviter de mourir en boucle au respawn
		await get_tree().create_timer(1.0).timeout
		is_invincible = false


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

func _get_stretch_target() -> float:
	if is_releasing_launch:
		return release_target_height
	if Input.is_action_pressed(action_launch) and is_on_floor():
		return _get_launch_charge_target()
	return _get_size_target()


func _update_stretch(delta: float) -> void:
	var target = _get_stretch_target()

	if is_releasing_launch:
		if not bounce_sound.playing:
			_play_bounce_sound()
		var spring_force = (target - height) * LAUNCH_RELEASE_STIFFNESS
		height_velocity += (spring_force - height_velocity * LAUNCH_RELEASE_DAMPING) * delta
		height += height_velocity * delta
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


# --------------------------- Sons ---------------------------
func _play_bounce_sound() -> void:
	var actual_compression = clamp(
		inverse_lerp(launch_charge_start_height, MIN_HEIGHT, height),
		0.0, 1.0
	)
	bounce_sound.pitch_scale = lerp(1.6, 0.7, actual_compression)
	bounce_sound.play(0.4)

func _update_stretch_sound() -> void:
	if Input.is_action_pressed(action_launch) and is_on_floor() and not is_releasing_launch:
		if not stretch_sound.playing:
			stretch_sound.play_random(1.0)
		if height <= MIN_HEIGHT + 0.5:
			stretch_sound.stop()
	else:
		stretch_sound.stop()


# --------------------------- Launch ---------------------------
func _compute_launch() -> void:
	if Input.is_action_just_released(action_launch) and is_on_floor():
		var margin = TILE_SIZE * 0.003
		var retraction_ratio = clamp(
			inverse_lerp(launch_charge_start_height, MIN_HEIGHT, height + margin),
			0.0, 1.0
		)
		pending_launch_force = retraction_ratio * MAX_LAUNCH_FORCE
		_launch_charge_ratio = clamp(
			inverse_lerp(MIN_HEIGHT, launch_charge_start_height, height),
			0.0, 1.0
		)
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
	var new_height = height + BODY_HEIGHT_OFFSET

	shape.size = Vector2(64.0, new_height)
	collision.position.y = -new_height / 2.0

	if test_move(global_transform, Vector2.ZERO):
		height = last_height
		var old_height = last_height + BODY_HEIGHT_OFFSET
		shape.size = Vector2(64.0, old_height)
		collision.position.y = -old_height / 2.0
	_update_occluder(shape)

	if desired_direction != 0:
		var flipped = desired_direction < 0
		body.flip_h = flipped
		head.flip_h = flipped
		feet.flip_h = flipped


func _update_animation() -> void:
	if not is_on_floor():
		if feet.animation != "jump":
			feet.play("jump")
	elif abs(desired_direction) > 0.01:
		feet.play("walk")
	else:
		feet.play("idle")


func _detect_ice() -> void:
	is_on_ice = false
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		if col == null:
			continue
		var rid = col.get_collider_rid()
		var layer = PhysicsServer2D.body_get_collision_layer(rid)
		if layer & 32:
			is_on_ice = true
			break
			
func _update_occluder(shape : RectangleShape2D):
	
	if light_occluder_2d.occluder != null:
		# On calcule les demi-mesures pour dessiner depuis le centre
		var w = shape.size.x / 2.0
		var h = shape.size.y / 2.0
		
		# On crée les 4 coins du rectangle pour correspondre à la collision
		light_occluder_2d.occluder.polygon = PackedVector2Array([
			Vector2(-w, -h), # Haut-gauche
			Vector2(w, -h),  # Haut-droit
			Vector2(w, h),   # Bas-droit
			Vector2(-w, h)   # Bas-gauche
			])
		light_occluder_2d.position.y = collision.position.y


# --------------------------- Footsteps ---------------------------
func _update_footsteps(delta: float) -> void:
	var is_walking = is_on_floor() and abs(desired_direction) > 0.01

	if not is_walking:
		_walk_time = 0.0
		_footstep_timer = 0.0
		return

	_walk_time += delta
	_footstep_timer -= delta

	var interval = lerp(footstep_interval_start, footstep_interval_normal, min(_walk_time, 1.0))

	if _footstep_timer <= 0.0:
		_footstep_timer = interval
		footstep_player.stream = _footstep_sounds[randi() % _footstep_sounds.size()]
		footstep_player.pitch_scale = randf_range(0.9, 1.1)
		footstep_player.play_random()

func _push_rigidbodies() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		if body is RigidBody2D:
			var n: Vector2 = collision.get_normal()

			# Seulement collisions latérales
			if absf(n.x) > 0.7:
				body.apply_central_force(Vector2(-n.x * PUSH_FORCE, 0.0))
