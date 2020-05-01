extends Node2D

var ASTEROIDSCENE = preload("res://Scenes/Asteroid.tscn")

var Asteroids
var Points

var GameOver = false

var PreviousShipPos

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_viewport().warp_mouse(Vector2(512, 300))
	
	Asteroids = 0
	Points = 0
	PreviousShipPos = Vector2(512.0, 300.0)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		SceneChanger.EndGame()
	elif GameOver:
		if event.is_action_pressed("ui_accept"):
			SceneChanger.ChangeScene("res://Scenes/Main.tscn")

func _process(delta):
	if not GameOver:
		var pos = .get_global_mouse_position()
		$Player.set_position(pos)
		var directionToBefore = PreviousShipPos - pos
		$Player/Sprite.rotation_degrees = clamp(directionToBefore.x, -45.0, 45.0)
		PreviousShipPos = pos
		
		$SpawnTimer.wait_time = max($SpawnTimer.wait_time - (delta * 0.005), 0.2)

func _on_SpawnTimer_timeout():
	var asteroid = ASTEROIDSCENE.instance()
	var angle = rand_range(-PI, PI)
	var pos = Vector2(512.0, 300.0) + (Vector2(cos(angle), sin(angle)) * 1000.0)
	asteroid.set_position(pos)
	asteroid.connect("Destroyed", self, "AsteroidDestroyed")
	$Asteroids.add_child(asteroid)
	Asteroids += 1
	$UI/Asteroids.text = "Asteroids: " + str(Asteroids)

func AsteroidDestroyed():
	Asteroids -= 1
	$UI/Asteroids.text = "Asteroids: " + str(Asteroids)

func _on_PointsTimer_timeout():
	if not GameOver:
		Points += Asteroids
		$UI/Score.text = "Score: " + str(Points)

func _on_Player_body_entered(body):
	if not GameOver:
		GameOver = true
		$Player/Sprite.visible = false
		$Player/Explosion.emitting = true
		$UI/End/Score.text = "Score: " + str(Points)
		$UI/End.visible = true
		$Explode.play()
