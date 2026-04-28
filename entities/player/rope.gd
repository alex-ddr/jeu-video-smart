extends Node2D

# --------------------------- Onready ---------------------------
@onready var line: Line2D = $Line2D

# --------------------------- Constants ---------------------------
const ROPE_LENGTH: float = 35.0
const ROPE_MAX_LENGTH: float = 60.0
const CONSTRAIN: float = 3.0
const GRAVITY: Vector2 = Vector2(0, 400.0)
const DAMPENING: float = 0.98
const ITERATIONS: int = 5

const SEGMENT_LAYER = 4 # bit 3 = layer 3
const COLLIDER_RADIUS: float = 2.0

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

	for i in num_segments:
		var area = Area2D.new()
		area.collision_layer = SEGMENT_LAYER
		area.collision_mask = 0
		var shape = CollisionShape2D.new()
		shape.shape = CircleShape2D.new()
		shape.shape.radius = COLLIDER_RADIUS
		area.add_child(shape)
		add_child(area)
		_colliders.append(area)

func _update_collider_positions(points: Array) -> void:
	for i in _colliders.size():
		if i < points.size():
			_colliders[i].global_position = points[i]
