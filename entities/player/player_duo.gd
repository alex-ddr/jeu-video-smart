extends Node2D

# --------------------------- Constants ---------------------------
const MAX_SPEED: float = 80.0
const MIN_SPEED: float = 65.0
const ACCELERATION: float = 200.0
const FRICTION: float = 200.0
const WEIGHT_CURVE: float = 2.0
const VELOCITY_THRESHOLD: float = 0.01
const JUMP_HORIZONTAL_BIAS: float = 0.3

# --------------------------- Onready ---------------------------
@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var line = $Line2D
@onready var bar_body = $StaticBody2D
@onready var rope_area: Area2D = $StaticBody2D/Area2D
@onready var rope_area_collision: CollisionShape2D = $StaticBody2D/Area2D/CollisionShape2D


var rope_length: float


func _ready() -> void:
	
	rope_area.collision_layer = 16
	rope_area.collision_mask = 8 # seulement la balle si balle = layer 4 / valeur 8
	rope_area.body_entered.connect(_on_rope_area_body_entered)

	var area_shape := RectangleShape2D.new()
	rope_area_collision.shape = area_shape
	
	
	var mat := PhysicsMaterial.new()
	mat.bounce = 2.0
	mat.friction = 0.0

	bar_body.physics_material_override = mat
	rope_length = p1.global_position.distance_to(p2.global_position)
	
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	
		
	
func _physics_process(delta: float) -> void:
	_apply_horizontal(delta)
	
	_enforce_rope_distance()
	
	_update_rope()



# --------------------------- Distance entre les deux joueur statique ---------------------------
func _enforce_rope_distance() -> void:
	var diff: Vector2 = p2.global_position - p1.global_position
	var current_distance := diff.length()

	if current_distance == 0:
		return

	var direction := diff / current_distance
	var error := current_distance - rope_length

	# Correction moitié-moitié
	var correction := direction * (error * 0.5)

	p1.global_position += correction
	p2.global_position -= correction

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
	# On calcule les points de départ et d'arrivée
	var pos_a = to_local(p1.global_position) + Vector2(-10, -p1.height)
	var pos_b = to_local(p2.global_position) + Vector2(10, -p2.height)
	
	var middle: Vector2 = (pos_a + pos_b) * 0.5
	var diff: Vector2 = pos_b - pos_a
	var length: float = diff.length()
	var angle: float = diff.angle()

	rope_area.position = middle
	rope_area.rotation = angle

	var rect := rope_area_collision.shape as RectangleShape2D
	rect.size = Vector2(length, 35) # 25 = épaisseur de détection
	# Mise à jour du visuel
	line.set_point_position(0, pos_a)
	line.set_point_position(1, pos_b)
	


func _on_rope_area_body_entered(body: Node) -> void:
	if body is RigidBody2D:
		var pos_a: Vector2 = line.get_point_position(0)
		var pos_b: Vector2 = line.get_point_position(1)

		var dir: Vector2 = (pos_b - pos_a).normalized()
		var normal: Vector2 = Vector2(-dir.y, dir.x)

		if normal.y > 0:
			normal = -normal

		normal.x *= 0.35
		normal = normal.normalized()

		body.linear_velocity = normal * 520.0
