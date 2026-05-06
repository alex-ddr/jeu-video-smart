extends AudioStreamPlayer

@export var pitch_min: float = 0.8
@export var pitch_max: float = 1.2

func play_random(begin_time: float = 0) -> void:
	pitch_scale = randf_range(pitch_min, pitch_max)
	play(begin_time)
	
