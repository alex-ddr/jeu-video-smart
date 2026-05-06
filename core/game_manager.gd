extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var intro_player: AudioStreamPlayer = $IntroPlayer

const SAVE_PATH := "user://save.json"
const MAIN_MENU := "res://ui/menu/menu.tscn"
const LEVELS := [
	"res://levels/level_tuto.tscn",
	"res://levels/level_grass_1.tscn",
	"res://levels/level_snow_1.tscn",
	"res://levels/level_desert_1.tscn",
	"res://levels/level_desert_2.tscn",
	"res://levels/level_space_1.tscn",
]

var save_data := {"unlocked_level" : 0}
var level_index : int = 0

func _ready() -> void:
	await get_tree().process_frame
	_play_intro_sound(8)
	_play_music()
	await IrisWipe.open_transition(4)
	level_index = 0
	load_game()

	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen_toggle"):
		fullscreen_toggle()

func go_to_menu() -> void:
	await IrisWipe.close_transition(0.5)
	get_tree().change_scene_to_file(MAIN_MENU)
	await IrisWipe.open_transition(0.5)
	if not music_player.playing:
		music_player.play()

func _play_intro_sound(nb_intros: int):
	var scene_path = get_tree().current_scene.scene_file_path
	if scene_path == MAIN_MENU:
		intro_player = AudioStreamPlayer.new()
		var intro_path = "res://assets/sounds/intro" + str(randi() % nb_intros + 1) + ".wav"
		intro_player.stream = load(intro_path)
		intro_player.volume_db = -3.0
		add_child(intro_player)
		intro_player.play()

func _play_music() -> void:
	music_player = AudioStreamPlayer.new()
	var stream = load("res://assets/musics/musique_jeu.mp3") as AudioStreamMP3
	stream.loop = true
	music_player.stream = stream
	music_player.volume_db = -3.0
	add_child(music_player)

	if intro_player :
		var intro_duration = intro_player.stream.get_length()
		await get_tree().create_timer(max(intro_duration - 0.5, 0.0)).timeout
	var scene_path = get_tree().current_scene.scene_file_path
	if scene_path == MAIN_MENU:
		music_player.play()


func start_game(level_index_new: int = level_index) -> void:
	Global.current_checkpoint_id = 0
	level_index = level_index_new
	var error :Error = get_tree().change_scene_to_file(LEVELS[level_index])
	if (error != OK):
		print("erreur au chargement du niveau d'index " + str(level_index))
	await IrisWipe.open_transition(0.5)
	
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, 0.3)
		await tween.finished
		music_player.stop()
		music_player.volume_db = -3.0

	
func load_next_level() -> void:
	await IrisWipe.close_transition(0.5)
	var next = level_index + 1
	print("unlocked_level :",save_data.get("unlocked_level", 0))
	if next > save_data.get("unlocked_level", 0):
		save_data["unlocked_level"] = next
		save_game() # On sauvegarde la progression sur le disque dur
	if next >= LEVELS.size():
		go_to_menu()
		return
	start_game(next)

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var result = JSON.parse_string(file.get_as_text())
	file.close()
	if result is Dictionary:
		save_data = result
		
func fullscreen_toggle() -> void:
	if (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
