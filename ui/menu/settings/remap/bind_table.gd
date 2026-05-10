@tool
extends GridContainer
@onready var grid = $"." 
@export var remap_button_scene: PackedScene = preload("res://ui/menu/settings/remap/remap_button.tscn")
@onready var title: Label = $Title

const PLAYERS_ACTION = [
	"up","down", "left", "right","jump", "launch"
]
# Cette fonction dit à l'inspecteur quelles propriétés afficher
func _get_property_list() -> Array:
	var properties = []
	
	# On récupère toutes les actions du projet
	var actions = InputMap.get_actions()
	
	# On les transforme en une seule chaîne de caractères séparée par des virgules
	# (Optionnel : on peut filtrer pour enlever les "ui_..." de base de Godot)
	var action_list = ""
	for a in actions:
		if not a.begins_with("ui_"): # On ne garde que nos actions perso
			action_list += a + ","
	
	# On crée la définition de la propriété pour l'inspecteur
	properties.append({
		"name": "action_to_remap",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": action_list
	})
	
	return properties

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for action in PLAYERS_ACTION:
		var lbl = Label.new()
		lbl.add_theme_color_override("font_color", title.get_theme_color("font_color"))
		lbl.add_theme_font_size_override("font_size", 25)
		lbl.text = action.capitalize()
		grid.add_child(lbl)
		
		var btn_p1 = remap_button_scene.instantiate()
		grid.add_child(btn_p1)
		btn_p1.set_action("p1_" + action) # On utilise la fonction de mise à jour
		
		var btn_p2 = remap_button_scene.instantiate()
		grid.add_child(btn_p2)
		btn_p2.set_action("p2_" + action)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
