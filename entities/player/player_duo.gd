extends Node2D

# --------------------------- Constants ---------------------------
const MAX_SPEED: float = 50.0
const MIN_SPEED: float = 10.0
const ACCELERATION: float = 200.0
const FRICTION: float = 200.0
const WEIGHT_CURVE: float = 2.0

const MAX_ROPE_DISTANCE: float = 120.0  # Distance max avant tension
const ROPE_REST_LENGTH: float = 60.0    # Distance à laquelle elle commence à pendre
const ROPE_SAG_AMPLITUDE: float = 40.0 # Profondeur max de la courbe
const ROPE_RESOLUTION: int = 13        # Nombre de segments dans la corde

const ROPE_IDEAL_LENGTH: float = 80.0  # Distance à partir de laquelle la corde tire
const SPRING_STIFFNESS: float = 1200.0 # Force du rappel (plus c'est haut, plus c'est rigide)
const SPRING_DAMPING: float = 10.0      # Amortissement pour éviter les oscillations infinies
# --------------------------- Onready ---------------------------
@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var line = $Line2D


func _ready() -> void:
	line.clear_points()
	for i in range(ROPE_RESOLUTION):
		line.add_point(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	_apply_movement_logic(delta)
	_update_rope()

# --------------------------- Horizontal movement ---------------------------
func _apply_movement_logic(delta : float) -> void:
	var diff = p2.global_position.x - p1.global_position.x
	var dist = abs(diff)
	var dir = sign(diff)

	# 1. Calcul de la force de la corde (si tendue)
	var rope_pull_force = 0.0
	if dist > ROPE_IDEAL_LENGTH:
		var stretch = dist - ROPE_IDEAL_LENGTH
		var rel_vel = p2.velocity.x - p1.velocity.x
		rope_pull_force = (stretch * SPRING_STIFFNESS) + (rel_vel * SPRING_DAMPING)

	var target_v1 = p1.desired_direction * _get_player_speed(p1)
	# Si P1 est immobile mais que la corde tire, on réduit la friction pour qu'il glisse
	var friction_p1 = FRICTION if p1.desired_direction != 0 or abs(rope_pull_force) < 10 else FRICTION * 0.2
	
	p1.velocity.x = move_toward(p1.velocity.x, target_v1, (ACCELERATION if target_v1 != 0 else friction_p1) * delta)
	p1.velocity.x += (dir * rope_pull_force * delta)
	var target_v2 = p2.desired_direction * _get_player_speed(p2)
	var friction_p2 = FRICTION if p2.desired_direction != 0 or abs(rope_pull_force) < 10 else FRICTION * 0.2
	
	p2.velocity.x = move_toward(p2.velocity.x, target_v2, (ACCELERATION if target_v2 != 0 else friction_p2) * delta)
	p2.velocity.x -= (dir * rope_pull_force * delta)
	
func _get_player_speed(player) -> float:
	var ratio = inverse_lerp(player.MIN_HEIGHT, player.MAX_HEIGHT, player.height)
	var penalty = pow(ratio, WEIGHT_CURVE)
	return lerp(MAX_SPEED, MIN_SPEED, penalty)


func _apply_horizontal(delta: float) -> void:
	var t1 = p1.desired_direction * _get_player_speed(p1)
	var t2 = p2.desired_direction * _get_player_speed(p2)
	
	p1.velocity.x = move_toward(p1.velocity.x, t1, ACCELERATION * delta)
	p2.velocity.x = move_toward(p2.velocity.x, t2, ACCELERATION * delta)

func _apply_spring_force(delta: float) -> void:
	var diff = p2.global_position.x - p1.global_position.x
	var dist = abs(diff)
	
	if dist > MAX_ROPE_DISTANCE:
		var stretch = dist - MAX_ROPE_DISTANCE
		
		# Force de rappel proportionnelle à l'étirement
		var spring_force = stretch * SPRING_STIFFNESS
		
		# Amortissement basé sur la différence de vitesse
		var rel_vel = p2.velocity.x - p1.velocity.x
		var damping = rel_vel * SPRING_DAMPING
		
		var total_force = (spring_force + damping) * delta
		
		# On tire l'un vers l'autre
		var direction = sign(diff) # 1 si P2 est à droite, -1 si à gauche
		p1.velocity.x += direction * total_force
		p2.velocity.x -= direction * total_force

# --------------------------- Rope ---------------------------
func _update_rope() -> void:
	var start_pos = to_local(p1.global_position) + Vector2(0, -p1.height)
	var end_pos = to_local(p2.global_position) + Vector2(0, -p2.height)
	var current_dist = start_pos.distance_to(end_pos)
	
	# Calcul du sag : plus on est proche, plus ça pend
	var sag_factor = 0.0
	if current_dist < ROPE_REST_LENGTH:
		# Ratio de 0 (tendu) à 1 (tout proche)
		sag_factor = inverse_lerp(ROPE_REST_LENGTH, 0, current_dist)
	
	for i in range(ROPE_RESOLUTION):
		var t = float(i) / float(ROPE_RESOLUTION - 1)
		# Interpolation linéaire entre les deux joueurs
		var pos = start_pos.lerp(end_pos, t)
		
		# Ajout de la courbe parabolique (y = x^2 inversé)
		# On utilise sin(PI * t) pour avoir une bosse au milieu (t=0.5)
		var curve = sin(PI * t) * ROPE_SAG_AMPLITUDE * sag_factor
		pos.y += curve
		
		line.set_point_position(i, pos)
