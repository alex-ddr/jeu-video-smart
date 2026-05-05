extends Node2D

@onready var player_duo = $PlayerBallCameraTrio/PlayerDuo
@onready var ball: RigidBody2D = $PlayerBallCameraTrio/Ball

var indice_checkpoint : int = 0

func _ready() -> void:
	print("Niveau chargé !")
	Global.checkpoint.connect(_on_checkpoint_reached)
	#On spawn au premier checkpoint
	indice_checkpoint = 0
	_spawn_at_checkpoint()

	
	# Met le nombre d'étoiles total dans le global pour l'UI
	Global.nb_stars_collected = 0
	Global.current_lives = Global.max_lives
	Global.lives_changed.emit()  #Pour actualiser l'affichage si l'UI est chargé avant
	var stars = find_child("Stars", true, false)
	if stars != null:
		Global.nb_stars_tot = stars.get_child_count()
		Global.stars_collected.emit()  # Pour actualiser l'affichage
		print("Étoiles trouvées : ", Global.nb_stars_tot)
	else:
		print("Aucun dossier d'étoiles trouvé dans ce niveau.")

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("respawn"):
		_spawn_at_checkpoint()

func _spawn_at_checkpoint() -> void:

	for cp in get_tree().get_nodes_in_group("checkpoints"):
		if cp.checkpoint_id == indice_checkpoint:
			ball.set_deferred("freeze", true)
			player_duo.p1.input_enabled = false
			player_duo.p2.input_enabled = false
			# Pour les joueurs (qui sont des CharacterBody2D), ça marche normalement :
			player_duo.p1.global_position = cp.global_position + Vector2(-200, 0)
			player_duo.p2.global_position = cp.global_position + Vector2(200, 0)
			player_duo.p1.velocity = Vector2.ZERO
			player_duo.p2.velocity = Vector2.ZERO
			player_duo.p1.height = Global.DEFAULT_HEIGHT
			player_duo.p2.height = Global.DEFAULT_HEIGHT

			# POUR LA BALLE (RigidBody2D) : On doit utiliser set_deferred pour forcer la physique
			var new_ball_pos = cp.global_position + Vector2(0, -180)
			ball.set_deferred("global_position", new_ball_pos)
			ball.set_deferred("linear_velocity", Vector2.ZERO)
			ball.set_deferred("angular_velocity", 0.0)
			
			await get_tree().create_timer(1.0).timeout
			ball.set_deferred("freeze", false)
			player_duo.p1.input_enabled = true
			player_duo.p2.input_enabled = true
			
	return


func _on_checkpoint_reached(id: int) -> void:
	if (id>indice_checkpoint):
		indice_checkpoint = id
