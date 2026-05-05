extends Area2D

@export var checkpoint_id: int = 0
@export var activated_texture: Texture2D 
@onready var sprite: Sprite2D = $Sprite2D 


var activated: bool = false
var ball_in : bool = false
var player_in : bool = false

func _ready() -> void:
	ball_in = false
	player_in = false
	add_to_group("checkpoints")
	#On peut ajouter ca si on veut que le checkpoint de départ soit directement activé
	#if(checkpoint_id==0):
	#	activated = true
	#	_set_visual_activated()


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
		_set_visual_activated()
		print("Checkpoint activé : ", checkpoint_id)
		
func _on_body_exited(body: Node2D) -> void:
	if not activated:
		if body.is_in_group("player"):
			player_in = false
		elif body.name == "Ball":
			ball_in = false
			
func _set_visual_activated():
	if sprite != null and activated_texture != null:
		sprite.texture = activated_texture
