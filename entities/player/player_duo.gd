extends Node2D

# --------------------------- Constants ---------------------------
const TILE_SIZE: float = Global.TILE_SIZE
const MAX_SPEED: float = TILE_SIZE * 3.125
const MIN_SPEED: float = TILE_SIZE * 0.625
const ACCELERATION: float = TILE_SIZE * 12.5
const FRICTION: float = TILE_SIZE * 12.5
const WEIGHT_CURVE: float = 2.0
const VELOCITY_THRESHOLD: float = 0.001
const ROPE_PULL_STRENGTH: float = TILE_SIZE * 37.5

# --------------------------- Onready ---------------------------
@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var rope = $Rope


func _physics_process(delta: float) -> void:
	_apply_horizontal(delta)
	_apply_rope_constraint()
	_update_rope()


# --------------------------- Horizontal movement ---------------------------

func _get_player_speed(player) -> float:
	var ratio = inverse_lerp(player.MIN_HEIGHT, player.MAX_HEIGHT, player.height)
	var penalty = pow(ratio, WEIGHT_CURVE)
	return lerp(MAX_SPEED, MIN_SPEED, penalty)


func _apply_horizontal(delta: float) -> void:
	var speed_p1 = _get_player_speed(p1)
	var speed_p2 = _get_player_speed(p2)

	var target_p1 = p1.desired_direction * speed_p1
	var target_p2 = p2.desired_direction * speed_p2

	if abs(target_p1) > VELOCITY_THRESHOLD:
		p1.velocity.x = move_toward(p1.velocity.x, target_p1, ACCELERATION * delta)
	else:
		p1.velocity.x = move_toward(p1.velocity.x, 0.0, FRICTION * delta)

	if abs(target_p2) > VELOCITY_THRESHOLD:
		p2.velocity.x = move_toward(p2.velocity.x, target_p2, ACCELERATION * delta)
	else:
		p2.velocity.x = move_toward(p2.velocity.x, 0.0, FRICTION * delta)


# --------------------------- Rope constraint ---------------------------
func _apply_rope_constraint() -> void:
	# On applique le pourcentage uniquement sur la hauteur (l'offset Y local)
	var hook_p1 = p1.global_position + Vector2(0, -p1.height * p1.ROPE_HOOK_POINT_PERC)
	var hook_p2 = p2.global_position + Vector2(0, -p2.height * p2.ROPE_HOOK_POINT_PERC)
	var distance = hook_p1.distance_to(hook_p2)

	if distance <= rope.ROPE_MAX_LENGTH:
		return

	var dir = (hook_p2 - hook_p1).normalized()
	var correction = distance - rope.ROPE_MAX_LENGTH

	var ratio_p1 = inverse_lerp(p1.MIN_HEIGHT, p1.MAX_HEIGHT, p1.height)
	var ratio_p2 = inverse_lerp(p2.MIN_HEIGHT, p2.MAX_HEIGHT, p2.height)
	var weight_p1 = 1.0 - ratio_p1
	var weight_p2 = 1.0 - ratio_p2
	var total_weight = weight_p1 + weight_p2

	if total_weight < 0.001:
		# Les deux sont au max → correction égale
		p1.global_position += dir * correction
		p2.global_position -= dir * correction
	else:
		p1.global_position += dir * correction * (weight_p1 / total_weight)
		p2.global_position -= dir * correction * (weight_p2 / total_weight)

# --------------------------- Rope visual ---------------------------

func _update_rope() -> void:
	# Même calcul ici pour l'affichage visuel de la corde
	var hook_p1 = p1.global_position + Vector2(0, -p1.height * p1.ROPE_HOOK_POINT_PERC)
	var hook_p2 = p2.global_position + Vector2(0, -p2.height * p2.ROPE_HOOK_POINT_PERC)
	rope.anchor_endpoints(hook_p1, hook_p2)
