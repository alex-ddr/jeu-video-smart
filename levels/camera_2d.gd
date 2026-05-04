extends Camera2D
@onready var p1 = $"../Player".p1
@onready var p2 = $"../Player".p2
var pos1 : Vector2
var pos2 : Vector2
var pos_cam : Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pos1 = p1.get_global_position()
	pos2 = p2.get_global_position()
	
	pos_cam = Vector2((pos1.x + pos2.x) / 2, (pos1.y + pos2.y) / 2)
	
	set_global_position(pos_cam)
	
	
