extends HBoxContainer
# On expose les réglages dans l'inspecteur
@export var bus_name: String = "Master"

@onready var value_label: Label = $Value
@onready var volume_slider: HSlider = $VolumeSlider

@onready var bus_index = AudioServer.get_bus_index(bus_name)

func _ready() -> void:
	var current_vol = ConfigManager.get_volume(bus_index)
	volume_slider.set_block_signals(true)
	volume_slider.value = current_vol
	volume_slider.set_block_signals(false)
	
	_update_display(current_vol)
	
	volume_slider.value_changed.connect(_on_value_changed)

func _on_value_changed(new_value: float) -> void:
	ConfigManager.set_volume(bus_index, new_value)
	_update_display(new_value)

func _update_display(val: float) -> void:
	if value_label:
		value_label.text = str(snappedf(val, 0.01))
