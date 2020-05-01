extends Node2D

var ASTEROIDSCENE = preload("res://Asteroid.tscn")

var Asteroids
var Points

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_viewport().warp_mouse(Vector2(512, 300))
	
	Asteroids = 0
	Points = 0

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		SceneChanger.EndGame()

func _process(delta):
	$Player.set_position(.get_global_mouse_position())

func _on_SpawnTimer_timeout():
	var asteroid = ASTEROIDSCENE.instance()
	var angle = rand_range(-PI, PI)
	var pos = Vector2(512.0, 300.0) + (Vector2(cos(angle), sin(angle)) * 1000.0)
	asteroid.set_position(pos)
	asteroid.connect("Destroyed", self, "AsteroidDestroyed")
	$Asteroids.add_child(asteroid)
	Asteroids += 1

func AsteroidDestroyed():
	Asteroids -= 1

func _on_PointsTimer_timeout():
	Points += Asteroids
