extends RigidBody2D

@export var bounce_force: float = 800.0 # Force de l'éjection, modifiable dans l'inspecteur

func _on_body_entered(body: Node) -> void:
	if body.name == "Ball" and body is RigidBody2D:
		# On calcule la direction entre le centre du bouncer et la balle
		var direction = global_position.direction_to(body.global_position)
		body.apply_central_impulse(direction * bounce_force)
