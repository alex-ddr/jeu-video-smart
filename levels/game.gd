extends Node2D

@onready var player_duo = $Player
@onready var ball: RigidBody2D = $Ball

func _ready() -> void:
	GameManager.load_game()
	_spawn_at_checkpoint()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("respawn"):
		respawn_at_checkpoint()


func respawn_at_checkpoint() -> void:
	GameManager.load_game()

	var saved_checkpoint_id: int = int(GameManager.save_data["checkpoint_id"])
	
	for checkpoint in get_tree().get_nodes_in_group("checkpoints"):
		if checkpoint.checkpoint_id == saved_checkpoint_id:
			respawn_at(checkpoint.global_position)
			return


func respawn_at(pos: Vector2) -> void:
	# Replace les deux joueurs autour du checkpoint
	player_duo.p1.global_position = pos + Vector2(-60, 0)
	player_duo.p2.global_position = pos + Vector2(60, 0)

	player_duo.p1.velocity = Vector2.ZERO
	player_duo.p2.velocity = Vector2.ZERO

	# Replace la balle
	ball.global_position = pos + Vector2(0, -180)
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0


func _spawn_at_checkpoint() -> void:
	var saved_level: String = str(GameManager.save_data["level"])

	if saved_level != scene_file_path:
		return

	var saved_checkpoint_id: int = int(GameManager.save_data["checkpoint_id"])
	for checkpoint in get_tree().get_nodes_in_group("checkpoints"):
		if checkpoint.checkpoint_id == saved_checkpoint_id:
			player_duo.global_position = checkpoint.global_position
			return
