extends Area2D

func _on_body_entered(body):
	
	if body.has_method("lose_life"):
		print("🌵 Le cactus a piqué la balle !")
		body.lose_life()
