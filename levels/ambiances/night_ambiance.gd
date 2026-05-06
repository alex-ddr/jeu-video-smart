@tool
extends CanvasModulate

func _ready() -> void:
	Global.set_torch_intensity_night()
	color = Color("003e62")
