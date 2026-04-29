extends RigidBody2D

func _ready() -> void:
	mass = 1.0
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.4
	physics_material_override.friction = 0.3
	gravity_scale = 1.0
