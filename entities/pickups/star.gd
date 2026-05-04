extends Area2D

func _on_body_entered(body: Node2D) -> void:
	Global.nb_stars_collected += 1;
	Global.stars_collected.emit()
	queue_free()
