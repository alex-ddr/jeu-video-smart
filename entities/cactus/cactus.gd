extends Area2D

func _on_body_entered(body):
	# On vérifie si c'est le joueur ET s'il possède la fonction lose_life
	if body.has_method("lose_life"):
		print("🌵 Le cactus a piqué la balle !")
		body.lose_life()
