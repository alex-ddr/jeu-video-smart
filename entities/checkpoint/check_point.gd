extends Area2D

@export var checkpoint_id: int = 0

var activated: bool = false

func _ready() -> void:
	add_to_group("checkpoints")


func _on_body_entered(body: Node) -> void:
	if activated:
		return

	if body.name != "Player1" and body.name != "Player2":
		return

	activated = true
	Global.checkpoint.emit(checkpoint_id)

	print("Checkpoint activé : ", checkpoint_id)
