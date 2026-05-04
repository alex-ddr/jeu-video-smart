extends Node2D

@onready var player_duo = $Player
@onready var ball: RigidBody2D = $Ball

func _ready() -> void:
	GameManager.load_game()
	_spawn_at_checkpoint(GameManager.save_data["checkpoint_id"])

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("respawn"):
		_spawn_at_checkpoint(GameManager.save_data["checkpoint_id"])

func _spawn_at_checkpoint(id: int) -> void:
	for cp in get_tree().get_nodes_in_group("checkpoints"):
		if cp.checkpoint_id == id:
			player_duo.p1.global_position = cp.global_position + Vector2(-60, 0)
			player_duo.p2.global_position = cp.global_position + Vector2(60, 0)
			player_duo.p1.velocity = Vector2.ZERO
			player_duo.p2.velocity = Vector2.ZERO
			ball.global_position = cp.global_position + Vector2(0, -180)
			ball.linear_velocity = Vector2.ZERO
			ball.angular_velocity = 0.0
			return
