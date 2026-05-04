extends Area2D

@export_file("*.tscn") var next_level_path: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.name != "Player1" and body.name != "Player2":
		return

	print("Félicitations ! Niveau terminé.")

	if next_level_path != "":
		get_tree().change_scene_to_file(next_level_path)
