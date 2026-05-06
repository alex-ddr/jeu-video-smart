extends Node2D

@onready var title_and: Sprite2D = $"Title&"
@onready var title_bounce: Sprite2D = $TitleBounce
@onready var title_bound: Sprite2D = $TitleBound

var _time: float = 0.0
var _bounce_height: float = 15.0
var _bounce_height_target: float = 15.0
var _bounce_timer: float = 0.0

	
func _process(delta: float) -> void:
	_time = fmod(_time + delta, TAU)

	var stretch_x = 1.0 + sin(_time * 1.5) * 0.12
	title_bound.scale.x = stretch_x

	_bounce_timer -= delta
	if _bounce_timer <= 0.0:
		_bounce_height_target = randf_range(8.0, 22.0)
		_bounce_timer = randf_range(0.3, 0.8)

	_bounce_height = lerp(_bounce_height, _bounce_height_target, delta * 5.0)
	title_bounce.position.y = -abs(sin(_time * 7.0)) * _bounce_height + 180
