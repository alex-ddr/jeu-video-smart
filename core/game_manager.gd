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

# --- AJOUT DU VERROU DE TRANSITION ---
var is_transitioning: bool = false 

func _ready() -> void:
	fullscreen_toggle()
	add_world_environment()
	await get_tree().process_frame
	_play_intro_sound(7)
	_play_music()
	await IrisWipe.open_transition(3)
	level_index = 0
	load_game()

	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen_toggle"):
		fullscreen_toggle()

func go_to_menu() -> void:
	# Sécurité
	if is_transitioning:
		return
	is_transitioning = true
	
	await IrisWipe.close_transition(0.5)
	get_tree().change_scene_to_file(MAIN_MENU)
	await get_tree().process_frame
	await get_tree().process_frame
	await add_world_environment()
	await IrisWipe.open_transition(0.5)
	if not music_player.playing:
		music_player.play()
		
	is_transitioning = false # Fin de la transition


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
	# Sécurité
	if is_transitioning: 
		return 
	is_transitioning = true
	
	await IrisWipe.close_transition(0.5)
	Global.current_checkpoint_id = 0
	level_index = level_index_new
	var error := get_tree().change_scene_to_file(LEVELS[level_index])
	if error != OK:
		print("erreur au chargement du niveau d'index " + str(level_index))
	await get_tree().process_frame
	await get_tree().process_frame
	await add_world_environment()
	await IrisWipe.open_transition(0.5)
	
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, 0.3)
		await tween.finished
		music_player.stop()
		music_player.volume_db = -3.0

	is_transitioning = false # Fin de la transition

	
func load_next_level() -> void:
	# Sécurité indispensable ici
	if is_transitioning: 
		return 
		
	var next = level_index + 1
	if next > save_data.get("unlocked_level", 0):
		save_data["unlocked_level"] = next
		save_game()
	if next >= LEVELS.size():
		await go_to_menu()
		return
	await start_game(next)

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

func add_world_environment() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	
	env.background_mode = Environment.BG_CANVAS
	
	env.glow_enabled = true
	env.set_glow_level(1, 0.8)
	env.set_glow_level(2, 0.5)
	env.set_glow_level(3, 0.2)
	env.glow_intensity = 0.8
	env.glow_strength = 0.5
	env.glow_bloom = 0.8
	env.glow_hdr_threshold = 1.2
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	
	env.adjustment_enabled = true
	env.adjustment_brightness = 0.9
	env.adjustment_contrast = 1.2
	env.adjustment_saturation = 1.2

	env_node.environment = env
	get_tree().current_scene.add_child(env_node)
