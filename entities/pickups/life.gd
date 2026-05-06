extends Area2D

var _time: float = 0.0

func _ready() -> void:
	global_position.y -= 20.0
	
func _process(delta: float) -> void:
	_time = fmod(_time + delta, TAU)
	global_position.y += sin(_time * 5.0)

func _on_body_entered(body: Node2D) -> void:
	if (Global.current_lives < Global.max_lives):
		Global.current_lives += 1
		Global.lives_changed.emit()
	queue_free()
