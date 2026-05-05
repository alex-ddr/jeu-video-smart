extends Area2D

func _on_body_entered(body):
	# On vérifie si l'objet qui entre possède la fonction pour perdre une vie
	if body.has_method("lose_life"):
		print("🌵 Touché par le cactus !")
		body.lose_life()
