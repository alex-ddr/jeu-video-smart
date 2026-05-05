extends Label

@onready var star_sound : AudioStreamPlayer = $"../../StarSound"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.stars_collected.connect(actu_score)
	actu_score("update")
	
func actu_score(state : String):
	if (state == "collected"):
		star_sound.play()
	set_text(str(Global.nb_stars_collected) + "/" +str(Global.nb_stars_tot))
	if(Global.nb_stars_collected == Global.nb_stars_tot):
		Global.all_stars_retrieved.emit()
