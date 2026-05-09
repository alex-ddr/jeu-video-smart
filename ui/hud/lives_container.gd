extends HBoxContainer

@export var ball_texture: Texture2D 

func _ready() -> void:
	# On se connecte au signal pour mettre à jour l'affichage
	Global.lives_changed.connect(update_lives_display)
	update_lives_display()
	
func update_lives_display() -> void:
	for child in get_children():
		child.queue_free()
		
	for i in range(Global.max_lives):
		var texture_rect = TextureRect.new()
		texture_rect.texture = ball_texture
		if i >= Global.current_lives:
			texture_rect.modulate.a = 0.5
		texture_rect.custom_minimum_size = Vector2(48, 48)
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		add_child(texture_rect)
