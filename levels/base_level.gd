extends Node2D

var player_duo
var ball: RigidBody2D

var indice_checkpoint : int = 0

func _ready() -> void:
	if has_node("PlayerBallCameraTrio/PlayerDuo"):
		player_duo = $PlayerBallCameraTrio/PlayerDuo
		ball = $PlayerBallCameraTrio/Ball if has_node("PlayerBallCameraTrio/Ball") else null
	else:
		player_duo = $PlayerDuo
		ball = $Ball if has_node("Ball") else null
		
	player_duo.add_to_group("players")

	Global.checkpoint.connect(_on_checkpoint_reached)
	#On spawn au premier checkpoint
	indice_checkpoint = GameManager.save_data.get("checkpoint_id", 0)
	_spawn_at_checkpoint()
	
	Global.nb_stars_collected = 0
	Global.current_lives = Global.max_lives
	Global.lives_changed.emit()  #Pour actualiser l'affichage si l'UI est chargé avant
	var stars = find_child("Stars", true, false)
	if stars != null:
		Global.nb_stars_tot = stars.get_child_count()
		Global.stars_collected.emit("update")  # Pour actualiser l'affichage
		print("Étoiles trouvées : ", Global.nb_stars_tot)
	else:
		print("Aucun dossier d'étoiles trouvé dans ce niveau.")
	
	if ball != null:
		ball.contact_monitor = true
		ball.max_contacts_reported = 4
		ball.body_shape_entered.connect(_on_ball_body_shape_entered)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("respawn"):
		player_duo.p1.lose_life()
		

func _spawn_at_checkpoint() -> void:
	for cp in get_tree().get_nodes_in_group("checkpoints"):
		if cp.checkpoint_id == indice_checkpoint:
			player_duo.p1.input_enabled = false
			player_duo.p2.input_enabled = false
			player_duo.p1.global_position = cp.global_position + Vector2(-200, 0)
			player_duo.p2.global_position = cp.global_position + Vector2(200, 0)
			player_duo.p1.velocity = Vector2.ZERO
			player_duo.p2.velocity = Vector2.ZERO
			player_duo.p1.height = Global.DEFAULT_HEIGHT
			player_duo.p2.height = Global.DEFAULT_HEIGHT

			if ball != null:
				ball.set_deferred("freeze", true)
				var new_ball_pos = cp.global_position + Vector2(0, -180)
				ball.set_deferred("global_position", new_ball_pos)
				ball.set_deferred("linear_velocity", Vector2.ZERO)
				ball.set_deferred("angular_velocity", 0.0)

			player_duo.p1.input_enabled = true
			player_duo.p2.input_enabled = true
			await get_tree().create_timer(1.0).timeout
			if ball != null:
				ball.set_deferred("freeze", false)
			player_duo.p1.input_enabled = true
			player_duo.p2.input_enabled = true
	return

func _on_checkpoint_reached(id: int) -> void:
	if (id>indice_checkpoint):
		indice_checkpoint = id
		
func _on_ball_body_shape_entered(body_rid: RID, _body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	var layer = PhysicsServer2D.body_get_collision_layer(body_rid)
	if layer & 64:  # layer 7 = acid_ground
		player_duo.p1.lose_life()
