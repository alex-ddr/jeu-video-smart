extends RigidBody2D

const UP_BOOST := 80.0
const BOUNCE_UP_SPEED := 600
const HORIZONTAL_DAMPING := 0.4
const MAX_SPEED := 400.0
const MAX_HORIZONTAL_SPEED := 200.0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var hit_bar := false

	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)

		if collider and collider.name == "StaticBody2D":
			hit_bar = true
			break

	if hit_bar:
		var v := state.linear_velocity

		# Rebond vers le haut, mais moins violent
		v.y = -BOUNCE_UP_SPEED

		# Réduit l'effet de l'inclinaison sur la trajectoire
		v.x *= HORIZONTAL_DAMPING

		# Limite la vitesse horizontale
		v.x = clamp(v.x, -MAX_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED)

		state.linear_velocity = v

	if state.linear_velocity.length() > MAX_SPEED:
		state.linear_velocity = state.linear_velocity.normalized() * MAX_SPEED


func _ready() -> void:
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	contact_monitor = true
	max_contacts_reported = 8
	gravity_scale = 0.8
	contact_monitor = true
	max_contacts_reported = 4

	var mat := PhysicsMaterial.new()
	mat.bounce = 1.0
	mat.friction = 0.0
	physics_material_override = mat

	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, Color.SKY_BLUE)
