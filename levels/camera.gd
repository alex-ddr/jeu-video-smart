extends Camera2D
@onready var p1 = $"../PlayerDuo".p1
@onready var p2 = $"../PlayerDuo".p2
@onready var ball = $"../Ball"
var pos1 : Vector2
var pos2 : Vector2
var dir1 : float
var dir2 : float
var pos_cam : Vector2
var pos_ball : Vector2

var last_dir = 1.0
var last_dir1 = 1.0
var last_dir2 = 1.0

@export var min_zoom : float = 0.2
@export var max_zoom : float = 0.6
@export var margin : float = 150.0  # Marge de sécurité en pixels pour pas que la balle touche le bord

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pos1 = p1.get_global_position()
	pos2 = p2.get_global_position()
	pos_ball = ball.get_global_position()
	
	var vp_size = get_viewport_rect().size
	
	dir1 = p1.desired_direction
	dir2 = p2.desired_direction
	
	if (dir1 != 0):
		last_dir1 = dir1
	if (dir2 != 0):
		last_dir2 = dir2
	
	if (last_dir1 != 0 && last_dir1 == last_dir2 && last_dir1 != last_dir):
		last_dir = last_dir1
	
	pos_cam = Vector2(((pos1.x + pos2.x) / 2) + (last_dir * vp_size.x / 3), (pos1.y + pos2.y) / 2)
	
	var diff_x = pos_cam.x - get_global_position().x
	if diff_x != 0:
		set_global_position(Vector2(get_global_position().x + diff_x / 45, pos_cam.y))
	
	# --- NOUVELLE LOGIQUE DE ZOOM ---
	_update_camera_zoom(vp_size)

func _update_camera_zoom(vp_size: Vector2) -> void:
	# 1. Calculer la distance entre le centre actuel de la caméra et la balle
	var dist_x = abs(pos_ball.x - get_global_position().x)
	var dist_y = abs(pos_ball.y - get_global_position().y)
	
	# 2. Déterminer le facteur de zoom nécessaire pour l'axe X et l'axe Y
	# On veut que (distance + marge) rentre dans la moitié de l'écran (vp_size / 2)
	var zoom_factor_x = (vp_size.x / 2) / (dist_x + margin)
	var zoom_factor_y = (vp_size.y / 2) / (dist_y + margin)
	
	# 3. On prend le zoom le plus petit (le plus restrictif) pour garantir la visibilité
	var target_zoom = min(zoom_factor_x, zoom_factor_y)
	
	# 4. On bride le zoom entre tes valeurs min et max
	target_zoom = clamp(target_zoom, min_zoom, max_zoom)
	
	# 5. Application fluide du zoom (interpolation)
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), 0.07)
	set_global_position(Vector2(get_global_position().x, min(get_global_position().y - dist_y / 3, get_global_position().y)))
