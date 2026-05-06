@tool
extends CanvasModulate


func _ready() -> void:
	Global.set_torch_intensity_snow()
	color = Color("e3ffff")
