extends Node2D

# --------------------------- Constants ---------------------------
const TILE_SIZE: float = Global.TILE_SIZE
const MAX_SPEED: float = TILE_SIZE * 3
const MIN_SPEED: float = TILE_SIZE * 1
const ACCELERATION: float = TILE_SIZE * 12.5
const FRICTION: float = TILE_SIZE * 12.5
const WEIGHT_CURVE: float = 2.0
const VELOCITY_THRESHOLD: float = 0.001
const ROPE_PULL_STRENGTH: float = TILE_SIZE * 37.5

# --------------------------- Onready ---------------------------
@onready var p1: CharacterBody2D = $Player1
@onready var p2: CharacterBody2D = $Player2
@onready var rope = $Rope


func _physics_process(delta: float) -> void:
	_apply_horizontal(delta)
	_apply_rope_constraint(delta)
	_update_rope()


# --------------------------- Horizontal movement ---------------------------

func _get_player_speed(player) -> float:
	var ratio = inverse_lerp(player.MIN_HEIGHT, player.MAX_HEIGHT, player.height)
	var penalty = pow(ratio, WEIGHT_CURVE)
	return lerp(MAX_SPEED, MIN_SPEED, penalty)


func _apply_horizontal(delta: float) -> void:
	var speed_p1 = _get_player_speed(p1)
	var speed_p2 = _get_player_speed(p2)
	
	_move_player(p1, p2, speed_p1, is_p1_hanging, delta)
	_move_player(p2, p1, speed_p2, is_p2_hanging, delta)
	
func _move_player(player: CharacterBody2D, other_player: CharacterBody2D, speed: float, hanging: bool, delta: float) -> void:
	if hanging:
		var hook_other = other_player.global_position + Vector2(0, -other_player.height - other_player.ROPE_HOOK_OFFSET)
		var hook_self  = player.global_position + Vector2(0, -player.height - player.ROPE_HOOK_OFFSET)
		var horizontal_offset = hook_other.x - hook_self.x

		# Force pendule

		# Input → élan
		player.velocity.x += horizontal_offset * 8.0 * delta
		player.velocity.x -= player.velocity.x * 0.8 * delta
		
		if abs(player.desired_direction) > 0.001:
			player.velocity.x += player.desired_direction * ACCELERATION * 0.4 * delta
	else:
		var target = player.desired_direction * speed
		if abs(target) > VELOCITY_THRESHOLD:
			player.velocity.x = move_toward(player.velocity.x, target, ACCELERATION * delta)
		else:
			player.velocity.x = move_toward(player.velocity.x, 0.0, FRICTION * delta)

# --------------------------- Rope constraint ---------------------------
var is_p1_hanging := false
var is_p2_hanging := false

func _apply_rope_constraint(delta: float) -> void:
	var hook_p1 = p1.global_position + Vector2(0, -p1.height - p1.ROPE_HOOK_OFFSET)
	var hook_p2 = p2.global_position + Vector2(0, -p2.height - p2.ROPE_HOOK_OFFSET)
	var distance = hook_p1.distance_to(hook_p2)
	
	_update_players_hanging(distance)
	
	if distance <= rope.ROPE_MAX_LENGTH:
		return
	
	var dir = (hook_p2 - hook_p1).normalized()
	var correction = distance - rope.ROPE_MAX_LENGTH

	var ratio_p1 = inverse_lerp(p1.MIN_HEIGHT, p1.MAX_HEIGHT, p1.height)
	var ratio_p2 = inverse_lerp(p2.MIN_HEIGHT, p2.MAX_HEIGHT, p2.height)
	var weight_p1 = 1.0 - ratio_p1
	var weight_p2 = 1.0 - ratio_p2
	var total_weight = weight_p1 + weight_p2

	var share_p1 = weight_p1 / total_weight if total_weight > 0.001 else 0.5
	var share_p2 = weight_p2 / total_weight if total_weight > 0.001 else 0.5

	# Correction de position
	p1.global_position += dir * correction * share_p1
	p2.global_position -= dir * correction * share_p2
	
	# Après la correction de position :
	var vel_along_p1 = p1.velocity.dot(dir)
	var vel_along_p2 = p2.velocity.dot(-dir)
	
	if (is_p1_hanging):
		if vel_along_p1 < 0:
			p1.velocity -= dir * vel_along_p1 * (1.0 + rope.ELASTICITY)
			var impulse = dir * vel_along_p1 * 0.4
			impulse.y = min(impulse.y, 0.0)
			p2.velocity += impulse
			
		for i in p1.get_slide_collision_count():
			var col = p1.get_slide_collision(i)
			if col == null:
				continue
			var normal = col.get_normal()
			if p2.desired_direction * normal.x < 0:
				p1.velocity.y += -abs(p1.velocity.x)*0.5
				pass
				
	if (is_p2_hanging):
		if vel_along_p2 < 0:
			p2.velocity += dir * vel_along_p2 * (1.0 + rope.ELASTICITY)
			var impulse = -dir * vel_along_p2 * 0.4
			impulse.y = min(impulse.y, 0.0)
			p1.velocity += impulse
			
		for i in p2.get_slide_collision_count():
			var col = p2.get_slide_collision(i)
			if col == null:
				continue
			var normal = col.get_normal()
			if p1.desired_direction * normal.x < 0:
				p2.velocity.y += -abs(p2.velocity.x)*0.5
				pass

func _update_players_hanging(distance: float):
	var rope_taut = distance > rope.ROPE_MAX_LENGTH
	is_p1_hanging = rope_taut and not p1.is_on_floor() and p1.global_position.y > p2.global_position.y
	is_p2_hanging = rope_taut and not p2.is_on_floor() and p1.global_position.y < p2.global_position.y

# --------------------------- Rope visual ---------------------------

func _update_rope() -> void:
	# Même calcul ici pour l'affichage visuel de la corde
	var hook_p1 = p1.global_position + Vector2(0, -p1.height - p1.ROPE_HOOK_OFFSET)
	var hook_p2 = p2.global_position + Vector2(0, -p2.height - p2.ROPE_HOOK_OFFSET)
	rope.anchor_endpoints(hook_p1, hook_p2)
