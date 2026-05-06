extends Node2D
@onready var main_light: PointLight2D = $AnimatedSprite2D/main_light
@onready var secondary_light: PointLight2D = $AnimatedSprite2D/secondary_light


# On sauvegarde l'énergie de base et l'échelle de base
var energie_base = 1.0 
var scale_base = Vector2(1.0, 1.0) # Remplace par tes valeurs de Scale si tu les as changées

func _process(_delta):
	energie_base = Global.torch_intensity
	# Fait trembler l'intensité de la lumière très rapidement (entre 80% et 120%)
	main_light.energy = energie_base * randf_range(0.8, 1.2)
	secondary_light.energy = energie_base * randf_range(0.8, 1.2)

	var tremblement_taille = randf_range(0.95, 1.05)
	main_light.scale = scale_base * tremblement_taille
	secondary_light.scale = scale_base * tremblement_taille
	
