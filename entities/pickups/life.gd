extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if (Global.current_lives < Global.max_lives):
		Global.current_lives += 1
		Global.lives_changed.emit()
	queue_free()
