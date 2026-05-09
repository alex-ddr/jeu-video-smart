extends Area2D

var ball_in : bool = false
var player_in : bool = false
var activated : bool = false # Le fameux verrou

@onready var bravo_sound : AudioStreamPlayer = $Bravo

func _ready() -> void:
	ball_in = false
	player_in = false
	activated = false

func _on_body_entered(body: Node) -> void:
	# Si la fin du niveau est déjà déclenchée, on ignore les autres collisions !
	if activated:
		return 

	if body.is_in_group("player"):
		player_in = true
	elif body.name == "Ball":
		ball_in = true
		
	if ball_in and player_in:
		# Condition de victoire remplie
		if Global.nb_stars_tot == Global.nb_stars_collected:
			activated = true # ON VERROUILLE ICI
			bravo_sound.play(2)
			GameManager.load_next_level()

func _on_body_exited(body: Node2D) -> void:
	# Si on a déjà gagné, inutile de mettre à jour ces variables
	if activated:
		return
		
	if body.is_in_group("player"):
		player_in = false
	elif body.name == "Ball":
		ball_in = false
