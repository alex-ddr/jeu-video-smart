extends Area2D

@export var checkpoint_id: int = 0

var activated: bool = false
var ball_in : bool = false
var player_in : bool = false

func _ready() -> void:
	ball_in = false
	player_in = false
	add_to_group("checkpoints")


func _on_body_entered(body: Node) -> void:
	if activated:
		return

	if body.is_in_group("player"):
		player_in = true
	elif body.name == "Ball":
		ball_in = true
	if ball_in and player_in:
		activated = true
		Global.checkpoint.emit(checkpoint_id)
		print("Checkpoint activé : ", checkpoint_id)
