extends CanvasLayer

# On récupère le nœud enfant ColorRect dès le chargement
@onready var color_rect: ColorRect = $ColorRect
const CIRCLE_OPEN_SIZE = 1.05
const CIRCLE_CLOSED_SIZE = 0.0

func _ready():
	# On s'assure que le ColorRect prend bien toute la taille de l'écran par sécurité
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# On ajuste le ratio du shader
	var viewport_size = get_viewport().get_visible_rect().size
	color_rect.material.set_shader_parameter("circle_size", CIRCLE_OPEN_SIZE)

	color_rect.material.set_shader_parameter("screen_ratio", viewport_size.x / viewport_size.y)

func close_transition(duration: float = 1.0, center_pos: Vector2 = Vector2(0.5, 0.5)):
	# On accède au shader via la référence color_rect
	color_rect.material.set_shader_parameter("center", center_pos)
	color_rect.material.set_shader_parameter("circle_size", CIRCLE_OPEN_SIZE)
	var tween = create_tween()
	# On anime la propriété sur le material du color_rect
	tween.tween_property(color_rect.material, "shader_parameter/circle_size", CIRCLE_CLOSED_SIZE, duration)
	await tween.finished

func open_transition(duration: float = 1.0, center_pos: Vector2 = Vector2(0.5, 0.5)):
	color_rect.material.set_shader_parameter("center", center_pos)
	color_rect.material.set_shader_parameter("circle_size", CIRCLE_CLOSED_SIZE)
	var tween = create_tween()
	tween.tween_property(color_rect.material, "shader_parameter/circle_size", CIRCLE_OPEN_SIZE, duration)
	await tween.finished
