extends Node2D

@onready var line = $Line2D

# On crée une tête de flèche simple avec du code (facultatif mais stylé)
func _ready():
	# On s'assure que la ligne a bien 2 points au départ
	line.points = [Vector2.ZERO, Vector2.ZERO]

func _compute_force_color(normalized_force) -> Color :
	var color_min = Color.BLUE
	var color_max = Color.FIREBRICK
	return color_min.lerp(color_max, normalized_force)

func update_arrow(force_vector: Vector2):
	# 1. On met à jour la position du deuxième point (la pointe)
	line.points[1] = force_vector
	
