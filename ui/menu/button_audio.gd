extends Button

const SoundPlayerScene = preload("uid://d0dw2t4yav5c2")

var hover_player
var click_player

func _ready() -> void:
	hover_player = SoundPlayerScene.instantiate()
	hover_player.stream = load("res://assets/sounds/hover.ogg")
	add_child(hover_player)

	click_player = SoundPlayerScene.instantiate()
	click_player.stream = load("res://assets/sounds/click.ogg")
	add_child(click_player)

	mouse_entered.connect(func(): hover_player.play_random())
	pressed.connect(func(): click_player.play_random())
