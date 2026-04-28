extends Line2D
const ROPE_RESOLUTION: int = 13        # Nombre de segments dans la corde
const COLLISION_WIDTH: int = 2.5
var body : StaticBody2D
func _init_segments() -> void :
	assert(ROPE_RESOLUTION % 2 != 0, "Rope resolution must be an odd number.")
	clear_points()
	for i in range(ROPE_RESOLUTION):
		add_point(Vector2.ZERO)
		
		
func _init_collisions() -> void : 
	body = StaticBody2D.new()
	body.set_collision_layer_value(1, false) 
	body.set_collision_mask_value(1, false) 
	body.set_collision_layer_value(2, true) 
	body.set_collision_mask_value(2, true) 
	add_child(body)

	for i in range(points.size() - 1):
		var new_shape = CollisionShape2D.new()
		body.add_child(new_shape)
		var rect = RectangleShape2D.new()
		new_shape.position = (points[i] + points[i + 1]) / 2
		new_shape.rotation = points[i].direction_to(points[i + 1]).angle()
		var length = points[i].distance_to(points[i + 1])
		rect.extents = Vector2(length / 2, 10)
		new_shape.shape = rect
	

func _update_collisions() -> void :
	var child_count = body.get_child_count()
	for i in range(child_count):
		var current_shape = body.get_child(i) as CollisionShape2D
		var current_rec = current_shape.shape as RectangleShape2D
		current_shape.position = (points[i] + points[i + 1]) / 2
		current_shape.rotation = points[i].direction_to(points[i + 1]).angle()
		var length = points[i].distance_to(points[i + 1])
		current_rec.extents = Vector2(length / 2, COLLISION_WIDTH)

func _process(_delta : float) -> void : 
	_update_collisions()

func init() -> void : 
	_init_segments()
	_init_collisions()
	_update_collisions()
	
