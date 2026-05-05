extends Node

# Stars
signal stars_collected
signal all_stars_retrieved

var nb_stars_tot: int = 0
var nb_stars_collected: int = 0

#Life
signal lives_changed()

var max_lives: int = 3
var current_lives: int = 3


const TILE_SIZE: int = 128
const GRAVITY: Vector2 = Vector2(0, TILE_SIZE * 25.0)

const DEFAULT_HEIGHT: float = 42.0
