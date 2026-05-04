extends Area2D

func _on_body_entered(body):
	# On vérifie si ce qui entre dans la zone est le joueur
	# (Assure-toi que ton joueur est dans un groupe nommé "player")
	if body.is_in_group("player"):
		print("Mort !")
		recommencer_niveau()

func recommencer_niveau():
	# Recharge la scène actuelle
	get_tree().reload_current_scene()
