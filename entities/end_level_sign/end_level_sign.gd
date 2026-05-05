extends Area2D

var ball_in : bool = false
var player_in : bool = false

func _ready() -> void:
	ball_in = false
	player_in = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in = true
	elif body.name == "Ball":
		ball_in = true
	if ball_in and player_in:
		if Global.nb_stars_tot == Global.nb_stars_collected:
			ball_in = false
			player_in = false
			GameManager.load_next_level()
	print("player_in : ", player_in)
	print("ball_in : ", ball_in)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in = false
	elif body.name == "Ball":
		ball_in = false
