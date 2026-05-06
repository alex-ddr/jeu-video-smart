@tool
extends CanvasModulate

@export_enum("desert", "night", "forest", "ice") var ambiance_type: String = "neutral"

func _ready() -> void:
	var data = Global.AMBIANCES[ambiance_type]
	color = data.color
	
	Global.current_ambiance_type = ambiance_type
	Global.current_ambiance_data = data
	
	Global.ambiance_changed.emit.call_deferred(ambiance_type, data)
