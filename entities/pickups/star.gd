extends Area2D

var _time: float = 0.0

func _ready() -> void:
	global_position.y -= 20.0
	
func _process(delta: float) -> void:
	_time = fmod(_time + delta, TAU)
	global_position.y += sin(_time * 5.0)

func _on_body_entered(body: Node2D) -> void:
	Global.nb_stars_collected += 1;
	Global.stars_collected.emit("collected")
	queue_free()
