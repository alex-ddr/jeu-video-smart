extends Area2D

var _time: float = 0.0

@onready var sfx: AudioStreamPlayer = $Sfx
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	global_position.y -= 20.0
	
func _process(delta: float) -> void:
	_time = fmod(_time + delta, TAU)
	global_position.y += sin(_time * 5.0)

func _on_body_entered(body: Node2D) -> void:
	Global.nb_stars_collected += 1
	Global.stars_collected.emit("collected")

	visible = false
	collision_shape_2d.position.y += 1000

	sfx.play(0.2)
	var duration: float = sfx.stream.get_length()
	await get_tree().create_timer(duration).timeout

	queue_free()
