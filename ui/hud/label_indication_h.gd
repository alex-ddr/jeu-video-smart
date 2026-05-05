extends Label

func _ready() -> void:
	visible = false
	Global.ball_ground.connect(_on_ball_ground)


func _on_ball_ground(ball_pos: Vector2) -> void:
	global_position = ball_pos + Vector2(-50, -100) 
	
	visible = true
	
	await get_tree().create_timer(10.0).timeout
	visible = false
