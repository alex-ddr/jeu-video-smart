extends RigidBody2D

# On ajoute un délai de sécurité où la balle ne peut pas perdre de vie
var is_invincible = false

func _ready() -> void:
	mass = 1.0
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.4
	physics_material_override.friction = 0.3
	gravity_scale = 1.0

# Cette fonction est appelée quand on touche le sol
func _on_ground_detector_body_entered(body: Node) -> void:
	# On vérifie l'invincibilité ET si le body est bien le sol (Layer 1)
	if is_invincible == false and (body is TileMap or body is TileMapLayer or body is StaticBody2D):
		lose_life()

func lose_life() -> void:
	Global.current_lives -= 1
	Global.lives_changed.emit()
	
	if Global.current_lives <= 0:
		Global.current_lives = Global.max_lives
		GameManager.go_to_menu()
	else:
		var level = get_tree().current_scene
		
		# 1. On bloque la balle temporairement
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		is_invincible = true
		
		# 2. On désactive temporairement la physique pour ne pas qu'elle rebondisse de partout
		set_deferred("freeze", true)
		
		# 3. On replace tout le monde
		if level.has_method("_spawn_at_checkpoint"):
			level._spawn_at_checkpoint(GameManager.save_data["checkpoint_id"])
			
		# 4. On crée un petit délai (timer d'1 sec) pour la remettre en jeu de façon "safe"
		await get_tree().create_timer(1.0).timeout
		
		# 5. On remet la balle en mouvement
		set_deferred("freeze", false)
		is_invincible = false
