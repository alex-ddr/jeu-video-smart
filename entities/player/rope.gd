extends Node2D

# --------------------------- Onready ---------------------------
@onready var line: Line2D = $Line2D
# --------------------------- Constants ---------------------------
const TILE_SIZE: float = Global.TILE_SIZE

const ROPE_LENGTH: float = TILE_SIZE * 2.1875
const ROPE_MAX_LENGTH: float = TILE_SIZE * 3.75
const CONSTRAIN: float = TILE_SIZE * 0.1875
const GRAVITY: Vector2 = Vector2(0, 400.0)
const DAMPENING: float = 0.98
const ITERATIONS: int = 5

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
		pos[i] += velocity + GRAVITY * delta


func _update_constrain() -> void:
	for i in range(point_count - 1):
		var dist = pos[i].distance_to(pos[i + 1])
		if dist < 0.001:
			continue
		var percent = (dist - CONSTRAIN) / dist
		var vec = pos[i + 1] - pos[i]

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

	var total = num_segments + (num_segments - 1)
	for i in total:
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
		var delta = points[i] - _colliders[collider_idx].global_position
		_colliders[collider_idx].move_and_collide(delta)
		pos[i] = _colliders[collider_idx].global_position
		collider_idx += 1

		if i < points.size() - 1:
			var mid = (points[i] + points[i + 1]) * 0.5
			var delta_mid = mid - _colliders[collider_idx].global_position
			_colliders[collider_idx].move_and_collide(delta_mid)
			collider_idx += 1
