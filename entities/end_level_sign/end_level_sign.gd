extends Area2D


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player") or Global.nb_stars_tot != Global.nb_stars_collected:
		return

	GameManager.load_next_level()
