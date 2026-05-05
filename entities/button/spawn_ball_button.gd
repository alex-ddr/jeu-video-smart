extends Area2D

signal pressed(id: String)

@export var id: String = "button_action_id"
@export var ball_scene: PackedScene= preload("uid://bykqjm2j5oxkr")

var _already_pressed = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _already_pressed or not body.is_in_group("player"):
		return
	_already_pressed = true
	$SwitchRed.visible = false
	$SwitchRedPressed.visible = true
	pressed.emit(id)
	
	if ball_scene:
		var ball = ball_scene.instantiate()
		ball.global_position = global_position + Vector2(400, -300)
		get_parent().add_child(ball)
