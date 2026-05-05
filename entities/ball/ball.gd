extends RigidBody2D

var is_invincible = false
var action_ball_jump: String = "ball_jump"
var _on_ground := false
var _can_jump_since: float = -1.0

const IDLE_VEL_THRESHOLD = 20.0
const JUMP_FORCE = 800.0
const GROUND_FRICTION = 0.88  # multiplicateur par frame (plus bas = freine plus vite)
const BLINK_SPEED = 7.0  # oscillations par seconde

@onready var sprite_default: Sprite2D = $SpriteDefault
@onready var sprite_pickup: Sprite2D = $SpritePickup

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
	var nearly_stopped = abs(linear_velocity.x) < IDLE_VEL_THRESHOLD
	var can_jump = _on_ground and nearly_stopped

	if can_jump:
		if _can_jump_since < 0.0:
			_can_jump_since = Time.get_ticks_msec() / 1000.0
		sprite_pickup.visible = true
		var t = Time.get_ticks_msec() / 1000.0 - _can_jump_since
		var alpha = (sin(t * BLINK_SPEED) + 1.0) / 2.0
		sprite_pickup.modulate.a = alpha
	else:
		_can_jump_since = -1.0
		sprite_pickup.visible = false
		sprite_pickup.modulate.a = 1.0

	if can_jump and Input.is_action_just_pressed(action_ball_jump):
		apply_central_impulse(Vector2(0, -JUMP_FORCE * mass))

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_on_ground = false
	for i in state.get_contact_count():
		var normal = state.get_contact_local_normal(i)
		if normal.y < -0.7:
			var collider_rid = state.get_contact_collider(i)
			var layer = PhysicsServer2D.body_get_collision_layer(collider_rid)
			if layer & 1:
				_on_ground = true
				break

	if _on_ground:
		state.linear_velocity.x *= GROUND_FRICTION

func _on_ground_detector_body_entered(body: Node) -> void:
	if is_invincible == false and _on_ground:
		Global.ball_ground.emit(global_position)
		if body.name == "Acide":
			lose_life()
		
	


func lose_life() -> void:
	Global.current_lives -= 1
	Global.lives_changed.emit()
	if Global.current_lives <= 0:
		Global.current_lives = Global.max_lives
		get_tree().call_deferred("reload_current_scene")
	else:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		is_invincible = true
		var level = get_tree().current_scene
		if level.has_method("_spawn_at_checkpoint"):
			level._spawn_at_checkpoint()
		else:
			print("pas de checkpoint")
		is_invincible = false
