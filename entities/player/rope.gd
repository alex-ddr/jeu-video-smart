extends Node2D

# --------------------------- Onready ---------------------------
@onready var line: Line2D = $Line2D

# --------------------------- Constants ---------------------------
const TILE_SIZE: float = Global.TILE_SIZE

const ROPE_LENGTH: float = TILE_SIZE * 1.25
const ROPE_MAX_LENGTH: float = TILE_SIZE * 4.5
const ROPE_YIELD_STRENGTH: float = 0.8
const CONSTRAIN: float = TILE_SIZE * 0.025
const GRAVITY: Vector2 = Global.GRAVITY
const DAMPENING: float = 0.98
const ITERATIONS: int = 30

const SEGMENT_LAYER = 4 # bit 3 = layer 3
const COLLIDER_RADIUS: float = TILE_SIZE * 0.0625

# --------------------------- Variables ---------------------------
var pos: Array = []
var pos_prev: Array = []
var point_count: int = 0
var rope_length: float = ROPE_LENGTH
var _colliders: Array = []

func _ready() -> void:
	point_count = int(ceil(ROPE_LENGTH / CONSTRAIN))
	for i in range(point_count):
		pos.append(Vector2(CONSTRAIN * i, 0))
		pos_prev.append(Vector2(CONSTRAIN * i, 0))
	
	_setup_colliders(point_count)


func anchor_endpoints(start: Vector2, end: Vector2) -> void:
	pos[0] = start
	pos_prev[0] = start
	pos[-1] = end
	pos_prev[-1] = end


func _physics_process(delta: float) -> void:
	_update_points(delta)
	for _i in range(ITERATIONS):
		_update_constrain()
	_update_collider_positions(pos)
	_draw_rope()


func _update_points(delta: float) -> void:
	for i in range(point_count):
		if i == 0 or i == point_count - 1:
			continue
		var velocity = (pos[i] - pos_prev[i]) * DAMPENING
		pos_prev[i] = pos[i]
		pos[i] += velocity + GRAVITY * delta * delta


func _update_constrain() -> void:
	# Calcule la limite par segment (la distance max qu'un maillon peut s'étirer)
	# Si on a 10 points, chaque segment peut s'étirer un peu pour atteindre le max
	var max_dist_per_segment = ROPE_MAX_LENGTH / float(point_count - 1)
	
	for i in range(point_count - 1):
		var dist = pos[i].distance_to(pos[i + 1])
		if dist < 0.001: continue
		
		# --- Logique élastique vs Rigide ---
		# Si on est au-delà du max, on ignore l'élasticité, on snap direct
		var is_at_limit = dist >= max_dist_per_segment
		
		# Pourcentage de correction (plus il est haut, plus c'est rigide)
		# 0.5 = élastique, 1.0 = rigide
		var stiffness = 1.0 if is_at_limit else 0.5 
		
		var percent = ((dist - CONSTRAIN) / dist) * stiffness
		var vec = pos[i + 1] - pos[i]

		# Appliquer la correction
		if i == 0:
			pos[i + 1] -= vec * percent
		elif i + 1 == point_count - 1:
			pos[i] += vec * percent
		else:
			pos[i] += vec * (percent / 2.0)
			pos[i + 1] -= vec * (percent / 2.0)


func _draw_rope() -> void:
	line.clear_points()
	for p in pos:
		line.add_point(to_local(p))

func _setup_colliders(num_segments: int) -> void:
	for c in _colliders:
		c.queue_free()
	_colliders.clear()

	for i in num_segments:
		var body = AnimatableBody2D.new()
		body.collision_layer = 4 # rope
		body.collision_mask = 1 | 8 # world && ball
		body.sync_to_physics = false
		var shape = CollisionShape2D.new()
		shape.shape = CircleShape2D.new()
		shape.shape.radius = COLLIDER_RADIUS
		body.add_child(shape)
		add_child(body)
		_colliders.append(body)

func _update_collider_positions(points: Array) -> void:
	var collider_idx = 0

	for i in points.size():
		# Collider sur le point
		var delta = points[i] - _colliders[collider_idx].global_position
		var collision = _colliders[collider_idx].move_and_collide(delta)
		pos[i] = _colliders[collider_idx].global_position  # ← pos[] pas points[]

		if collision:
			var hit = collision.get_collider()
			if hit is RigidBody2D:
				# Pousse la corde vers le bas selon la masse
				pos[i].y += hit.mass * ROPE_YIELD_STRENGTH
				# Réapplique immédiatement au collider
				_colliders[collider_idx].global_position = pos[i]
				hit.apply_central_impulse(collision.get_normal() * -hit.mass * 50.0)
		collider_idx += 1
