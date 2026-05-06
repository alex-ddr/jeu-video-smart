extends RigidBody2D

var is_invincible = false
var action_ball_jump: String = "ball_jump"
var _on_ground := false
var _can_jump_since: float = -1.0
var is_on_ice: float = false

const IDLE_VEL_THRESHOLD = 15.0
const JUMP_FORCE = 800.0
const GROUND_FRICTION = 0.88  # multiplicateur par frame (plus bas = freine plus vite)
const ICE_FRICTION = 0.995
const BLINK_SPEED = 7.0  # oscillations par seconde

@onready var sprite_default: Sprite2D = $SpriteDefault
@onready var sprite_pickup: Sprite2D = $SpritePickup

@onready var swoosh: AudioStreamPlayer = $Swoosh

# -------------------------- ball sounds ----------------------
@onready var ball_sound: AudioStreamPlayer = $BallImpact

const BOUNCE_MIN_IMPACT := 120.0
const BOUNCE_MAX_IMPACT := 900.0

var _was_on_ground := false

@onready var ball_wind_sound: AudioStreamPlayer = $BallWind

var _air_time: float = 0.0
var _was_touching: bool = false
var _wind_played: bool = false

const WIND_DELAY := 1.5

const PLAYER_BOUNCE: float = 0.18
const PLAYER_RADIUS := 32.0
const BALL_RADIUS := 28.0
const SEPARATION_MARGIN := 2.0


func _ready() -> void:
	sprite_pickup.visible = false
	mass = 2.0
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.075
	physics_material_override.friction = 1
	gravity_scale = 1.0
	contact_monitor = true
	max_contacts_reported = 4
	

func _physics_process(_delta: float) -> void:
	_resolve_player_overlap()
	var nearly_stopped = (abs(linear_velocity.x) < IDLE_VEL_THRESHOLD and abs(linear_velocity.y) <= 10.0)
	var can_jump = _on_ground and nearly_stopped

	_play_wind_sound(_delta)
	
	if can_jump:
		sprite_pickup.visible = true
		if Input.is_action_just_pressed(action_ball_jump):
			swoosh.pitch_scale = 1.5
			swoosh.play()
			apply_central_impulse(Vector2(0, -JUMP_FORCE * mass))
	else:
		sprite_pickup.visible = false
	

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_on_ground = false
	is_on_ice = false
	
	for i in state.get_contact_count():
		var normal = state.get_contact_local_normal(i)
		var collider_rid = state.get_contact_collider(i)
		var layer = PhysicsServer2D.body_get_collision_layer(collider_rid)

		if normal.y < -0.7:
			if layer & 4:
				_stop_wind_sound()
			if layer & 2:
				_on_ground = true
				_stop_wind_sound()
				break

			if layer & 1 or layer & 16 or layer & 32 or layer & 64:
				_on_ground = true
				is_on_ice = layer & 32 != 0
				_stop_wind_sound()
				break

	_play_ball_impact_sound(state)
	_was_on_ground = _on_ground
	physics_material_override.friction = 0.0 if is_on_ice else 1.0

	if _on_ground:
		if is_on_ice:
			state.linear_velocity.x *= ICE_FRICTION
		else:
			state.linear_velocity.x *= GROUND_FRICTION
			
func _on_ground_detector_body_entered(body: Node) -> void:
	if is_invincible == false and _on_ground:
		Global.ball_ground.emit(global_position)
		if body.name == "Acide":
			lose_life()
		
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
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		is_invincible = true

		var level = get_tree().current_scene
		if level.has_method("_spawn_at_checkpoint"):
			level._spawn_at_checkpoint()
		else:
			print("Attention: La scène actuelle n'a pas de méthode '_spawn_at_checkpoint'")
			
		# Petit délai d'invincibilité (1 seconde) pour éviter de mourir en boucle au respawn
		await get_tree().create_timer(1.0).timeout
		is_invincible = false

func _play_ball_impact_sound(state: PhysicsDirectBodyState2D):
	var impact_speed: float = absf(state.linear_velocity.y)

	if _on_ground and not _was_on_ground and impact_speed > BOUNCE_MIN_IMPACT:
		var t = clamp(inverse_lerp(BOUNCE_MIN_IMPACT, BOUNCE_MAX_IMPACT, impact_speed), 0.0, 1.0)
		ball_sound.volume_db = lerp(-4, 5, t)
		ball_sound.play_random()
		_stop_wind_sound()
		
func _play_wind_sound(_delta):
	if _on_ground:
		_air_time = 0.0
		_wind_played = false
	else:
		_air_time += _delta
		if _air_time >= WIND_DELAY and not _wind_played and not ball_wind_sound.playing:
			ball_wind_sound.play_random()
			_wind_played = true

func _stop_wind_sound():
	if ball_wind_sound.playing:
		ball_wind_sound.stop()
		
func _resolve_player_overlap() -> void:
	var players = get_tree().get_nodes_in_group("players")
	
	for player in players:
		if player == null:
			continue
		
		var to_ball = global_position - player.global_position
		var dist = to_ball.length()
		var min_dist = PLAYER_RADIUS + BALL_RADIUS + SEPARATION_MARGIN
		
		if dist < min_dist:
			var dir = to_ball.normalized() if dist > 0.001 else Vector2.RIGHT
			var push_out = dir * (min_dist - dist)
			global_position += push_out
			
			# On annule la vitesse qui va vers le joueur pour éviter de retraverser
			var vn = linear_velocity.dot(dir)
			if vn < 0.0:
				linear_velocity -= dir * vn
