@tool
extends Button

var action_to_remap: String = ""
@export var action_name: String # Le nom de l'action dans l'Input Map

@onready var rebind_button: Button = $"."

var is_rebinding: bool = false

func _ready() -> void:
	print("ready")
	print(action_name)
	_update_button_text()
	
func set_action(new_name: String) -> void:
	action_name = new_name
	_update_button_text()

func _update_button_text() -> void:
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		rebind_button.text = events[0].as_text().trim_suffix(" (Physical)")
	else:
		rebind_button.text = "Not bound"
	
func _unhandled_input(event: InputEvent) -> void:
	if is_rebinding:
		if event is InputEventKey or event is InputEventMouseButton:
			InputMap.action_erase_events(action_name)
			print(event)
			InputMap.action_add_event(action_name, event)
			is_rebinding = false
			_update_button_text()
			get_viewport().set_input_as_handled()


func _on_pressed() -> void:
	is_rebinding = true
	rebind_button.text = "???"
