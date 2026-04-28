extends Line2D
const ROPE_RESOLUTION: int = 13        # Nombre de segments dans la corde
var body : AnimatableBody2D

func _init_segments() -> void :
	assert(ROPE_RESOLUTION % 2 != 0, "Rope resolution must be an odd number.")
	clear_points()
	for i in range(ROPE_RESOLUTION):
		add_point(Vector2.ZERO)
		
		
func _init_collisions() -> void : 
	body = AnimatableBody2D.new()

	body.set_collision_layer_value(2, true) 
	body.set_collision_mask_value(2, true) 

	add_child(body)
	for i in points.size() - 1:
		var new_shape : CollisionShape2D = CollisionShape2D.new()
		body.add_child(new_shape)
		var segment : SegmentShape2D = SegmentShape2D.new()
		segment.a = points[i]
		segment.b = points[i + 1]
		new_shape.shape = segment
		
	
		
func _update_collisions() -> void :
	for i in body.get_children().size():
		var current_seg = body.get_child(i).shape
		current_seg.a = points[i]
		current_seg.b = points[i + 1]

func _process(_delta : float) -> void : 
	_update_collisions()

func init() -> void : 
	_init_segments()
	_init_collisions()
	
