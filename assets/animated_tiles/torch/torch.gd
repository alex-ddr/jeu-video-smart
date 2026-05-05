extends Node2D
@onready var point_light_2d: PointLight2D = $AnimatedSprite2D/PointLight2D


# On sauvegarde l'énergie de base et l'échelle de base
var energie_base = 1.0 
var scale_base = Vector2(1.0, 1.0) # Remplace par tes valeurs de Scale si tu les as changées

func _process(_delta):
	# Fait trembler l'intensité de la lumière très rapidement (entre 80% et 120%)
	point_light_2d.energy = energie_base * randf_range(0.8, 1.2)
	
	# Optionnel : Fait trembler légèrement la taille de la lumière
	var tremblement_taille = randf_range(0.95, 1.05)
	point_light_2d.scale = scale_base * tremblement_taille
