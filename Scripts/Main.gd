extends Node2D

var ASTEROIDSCENE = preload("res://Scenes/Asteroid.tscn")
var EXPLOSIONSCENE = preload("res://Scenes/Explosion.tscn")
var TEXTEFFECTSCENE = preload("res://Scenes/TextEffect.tscn")

var Asteroids
var Points
var Highscore

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
	asteroid.connect("ExtraPoints", self, "ExtraPoints")
	$Asteroids.add_child(asteroid)
	Asteroids += 1
	$UI/Asteroids.text = "Asteroids: " + str(Asteroids)

func AsteroidDestroyed(pos):
	var explosion = EXPLOSIONSCENE.instance()
	explosion.set_position(pos)
	$Effects.add_child(explosion)
	Asteroids -= 1
	$UI/Asteroids.text = "Asteroids: " + str(Asteroids)

func ExtraPoints(points, text, pos):
	if not GameOver:
		Points += points
		$UI/Score.text = "Score: " + str(Points)
		ShowText(text, pos)

func _on_PointsTimer_timeout():
	if not GameOver:
		Points += Asteroids
		$UI/Score.text = "Score: " + str(Points)

func _on_Player_body_entered(body):
	if not GameOver:
		GameOver = true
		$Player/Sprite.visible = false
		$Player/Explosion.emitting = true
		LoadHighScore()
		if Points > Highscore:
			Highscore = Points
			SaveHighScore()
		$UI/End/Score.text = "Score: " + str(Points)
		$UI/End/HighScore.text = "Highscore: " + str(Highscore)
		$UI/End.visible = true
		$UI/Asteroids.visible = false
		$UI/Score.visible = false
		$Explode.play()

func ShowText(text, pos):
	var textEffect = TEXTEFFECTSCENE.instance()
	textEffect.set_position(pos)
	textEffect.Text = text
	$Effects.add_child(textEffect)

func LoadHighScore():
	Highscore = 0
	var config = ConfigFile.new()
	var result = config.load("user://settings.cfg")
	if result == OK:
		Highscore = config.get_value("defaults", "highscore", 0)

func SaveHighScore():
	var config = ConfigFile.new()
	var result = config.load("user://settings.cfg")
	config.set_value("defaults", "highscore", Highscore)
	config.save("user://settings.cfg")
