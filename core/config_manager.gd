extends Node

@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var sfx_bus = AudioServer.get_bus_index("SFX")


const DEFAULT_VOLUME = 0.5
const VOLUME_RATIO = 1 / DEFAULT_VOLUME #Pour que le default volume soit = à 0dB


func _ready() -> void:
	set_volume(master_bus, DEFAULT_VOLUME)
	set_volume(music_bus, DEFAULT_VOLUME)
	set_volume(sfx_bus, DEFAULT_VOLUME)

func get_volume(bus_index:int) -> float :
	var db = AudioServer.get_bus_volume_db(bus_index)
	var linear = db_to_linear(db)
	return linear / VOLUME_RATIO
	
func set_volume(bus_index: int, linear_value: float):
	
	var db_value = (linear_to_db(linear_value * VOLUME_RATIO))
	print("volume set at" + str(db_value))

	AudioServer.set_bus_volume_db(bus_index, db_value)
	AudioServer.set_bus_mute(bus_index, linear_value < 0.01)
