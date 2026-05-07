extends Control

@onready var master_value_label: Label = $CenterContainer/VBoxContainer/HBoxContainer/Value
@onready var master_volume_slider: HSlider = $CenterContainer/VBoxContainer/HBoxContainer/MasterVolumeSlider

@onready var music_volume_slider: HSlider = $CenterContainer/VBoxContainer/MusicContainer/MusicVolumeSlider
@onready var music_volume_label: Label = $CenterContainer/VBoxContainer/MusicContainer/Value

@onready var sfx_volume_slider: HSlider = $CenterContainer/VBoxContainer/SFXContainer/SFXVolumeSlider
@onready var sfx_volume_label: Label = $CenterContainer/VBoxContainer/SFXContainer/Value


func _ready() -> void:
	pass

func _on_back_pressed() -> void:
	GameManager.go_to_menu()
