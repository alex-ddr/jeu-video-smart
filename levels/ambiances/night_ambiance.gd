@tool
extends CanvasModulate

func _ready() -> void:
	Global.set_torch_intensity_night()
	color = Color("b7c7ffff")
