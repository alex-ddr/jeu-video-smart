extends Label



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.Star_collected.connect(actu_score)
	actu_score()
	
func actu_score():
	set_text(str(Global.nb_stars_collected) + "/" +str(Global.nb_stars_tot))
