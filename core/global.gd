extends Node

signal Star_collected

var nb_stars_tot : int = 0
var nb_stars_collected : int = 0

var current_level: int = 1
const TILE_SIZE: int = 128
const GRAVITY: Vector2 = Vector2(0, TILE_SIZE * 25.0)
