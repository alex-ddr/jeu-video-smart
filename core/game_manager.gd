extends Node

# --- Variables Globales ---
var current_level: int = 1

# Tu pourras ajouter ici des fonctions comme :
# func load_next_level():
#     get_tree().change_scene_to_file("res://levels/level_02.tscn")

const SAVE_PATH := "user://save.json"

var save_data := {
	"level": "level_1",
	"checkpoint_id": 0
}

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var result = JSON.parse_string(content)
	if result is Dictionary:
		save_data = result
