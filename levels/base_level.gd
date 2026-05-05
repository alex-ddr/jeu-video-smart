extends Node2D

@onready var player_duo = $Players/PlayerDuo
@onready var ball: RigidBody2D = $Players/Ball

func _ready() -> void:
	print("Niveau chargé !")
	GameManager.load_game()
	_spawn_at_checkpoint(GameManager.save_data["checkpoint_id"])
	
	# Met le nombre d'étoiles total dans le global pour l'UI
	var stars = find_child("Stars", true, false)
	if stars != null:
		Global.nb_stars_tot = stars.get_child_count()
		Global.stars_collected.emit()  # Pour actualiser l'affichage
		print("Étoiles trouvées : ", Global.nb_stars_tot)
	else:
		print("Aucun dossier d'étoiles trouvé dans ce niveau.")

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("respawn"):
		_spawn_at_checkpoint(GameManager.save_data["checkpoint_id"])

func _spawn_at_checkpoint(id: int) -> void:
	for cp in get_tree().get_nodes_in_group("checkpoints"):
		if cp.checkpoint_id == id:
			# Pour les joueurs (qui sont des CharacterBody2D), ça marche normalement :
			player_duo.p1.global_position = cp.global_position + Vector2(-200, 0)
			player_duo.p2.global_position = cp.global_position + Vector2(200, 0)
			player_duo.p1.velocity = Vector2.ZERO
			player_duo.p2.velocity = Vector2.ZERO

			# POUR LA BALLE (RigidBody2D) : On doit utiliser set_deferred pour forcer la physique
			var new_ball_pos = cp.global_position + Vector2(0, -180)
			ball.set_deferred("global_position", new_ball_pos)
			ball.set_deferred("linear_velocity", Vector2.ZERO)
			ball.set_deferred("angular_velocity", 0.0)
			
		return
