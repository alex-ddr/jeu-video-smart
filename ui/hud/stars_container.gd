extends HBoxContainer

@export var star_texture: Texture2D

func _ready() -> void:
	Global.stars_collected.connect(update_stars_display)
	update_stars_display("")

func update_stars_display(_arg) -> void:
	for child in get_children():
		child.queue_free()

	for i in range(Global.nb_stars_tot):
		var texture_rect = TextureRect.new()
		texture_rect.texture = star_texture
		if i >= Global.nb_stars_collected:
			texture_rect.modulate.a = 0.3
		texture_rect.custom_minimum_size = Vector2(48, 48)
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		add_child(texture_rect)
