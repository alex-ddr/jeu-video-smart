extends Area2D

@export var checkpoint_id: int = 0

var activated: bool = false

func _ready() -> void:
	add_to_group("checkpoints")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if activated:
		return

	if body.name != "Player1" and body.name != "Player2":
		return

	activated = true

	GameManager.save_data["level"] = get_tree().current_scene.scene_file_path
	GameManager.save_data["checkpoint_id"] = checkpoint_id
	GameManager.save_game()

	print("Checkpoint activé : ", checkpoint_id)
