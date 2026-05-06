extends Node2D
@onready var main_light: PointLight2D = $AnimatedSprite2D/main_light
@onready var secondary_light: PointLight2D = $AnimatedSprite2D/secondary_light

var light_intensity = 0.0 
var scale_base = Vector2(1.0, 1.0) # Remplace par tes valeurs de Scale si tu les as changées

var _flicker_timer: float = 0.0
const FLICKER_RATE: float = 0.05

func _ready() -> void:
	Global.ambiance_changed.connect(_on_ambiance_changed)
	
	if Global.current_ambiance_type != "":
		_on_ambiance_changed(Global.current_ambiance_type, Global.current_ambiance_data)
	

func _process(delta):
	_flicker_timer -= delta
	if _flicker_timer <= 0.0:
		_flicker_timer = FLICKER_RATE
		secondary_light.energy = light_intensity * randf_range(0.8, 1.2)
	var tremblement_taille = randf_range(0.95, 1.05)
	secondary_light.scale = scale_base * tremblement_taille
	
func _on_ambiance_changed(type: String, data: Dictionary) -> void:
	print(data.light_intensity)
	light_intensity = data.light_intensity
	main_light.energy = light_intensity
	secondary_light.energy = light_intensity
	
