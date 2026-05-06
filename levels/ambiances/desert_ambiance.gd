@tool
extends CanvasModulate


func _ready() -> void:
	Global.set_torch_intensity_desert()
	color = Color("fcf1da")
