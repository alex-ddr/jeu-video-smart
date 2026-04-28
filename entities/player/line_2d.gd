extends Line2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var newStaticBody = StaticBody2D.new()
	add_child(newStaticBody)
	for i in points.size() - 1:
		var new_shape = CollisionShape2D.new()
		newStaticBody.add_child(new_shape)
		var segment = SegmentShape2D.new()
		segment.a = points[i]
		segment.b = points[i + 1]
		new_shape.shape = segment


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
