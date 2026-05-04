extends Area2D

func _on_body_entered(body):
	# On vérifie si c'est bien le joueur (groupe "player")
	if body.is_in_group("player"):
		print("Mort par cactus !")
		# On demande de recharger la scène de manière différée
		get_tree().call_deferred("reload_current_scene")
