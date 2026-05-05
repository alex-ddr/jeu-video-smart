extends RigidBody2D

@onready var collision_shape_2d = $CollisionShape2D

func destroy():
	collision_shape_2d.set_deferred("disabled", true) 
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.name == "Ball":
		print("Touché par la balle !")
		destroy()
