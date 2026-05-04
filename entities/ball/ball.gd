extends RigidBody2D

const BOUNCE_SPEED := 1000
const MAX_SPEED := 1400.0

# 0.0 = vertical pur
# 1.0 = suit totalement l'inclinaison
const ANGLE_INFLUENCE := 0.9

func _ready() -> void:
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	contact_monitor = true
	max_contacts_reported = 8
	gravity_scale = 0.8

	var mat := PhysicsMaterial.new()
	mat.bounce = 0.0
	mat.friction = 0.0
	physics_material_override = mat


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	for i in range(state.get_contact_count()):
		var normal: Vector2 = state.get_contact_local_normal(i)

		if normal.y < -0.2:
			var vertical: Vector2 = Vector2.UP
			var angled: Vector2 = normal.normalized()

			if angled.y > 0.0:
				angled = -angled

			var bounce_dir: Vector2 = vertical.lerp(angled, ANGLE_INFLUENCE).normalized()

			# même si la balle est lente, on force un rebond minimum
			if state.linear_velocity.y > -120.0:
				state.linear_velocity = bounce_dir * BOUNCE_SPEED

			break

	if state.linear_velocity.length() > MAX_SPEED:
		state.linear_velocity = state.linear_velocity.normalized() * MAX_SPEED
func _draw() -> void:
	draw_circle(Vector2.ZERO, 32.0, Color.SKY_BLUE)
