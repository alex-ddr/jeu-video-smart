extends Area2D

func _on_body_entered(body):
	# On vérifie si l'objet qui tombe possède la fonction pour perdre une vie
	if body.has_method("lose_life"):
		print("💀 Tombé dans la zone de mort !")
		body.lose_life()
