extends Control

var Text = """Project Icarus Captain Log Nr. 472:

Today is the day.
Today i'll finally show those cowards at Daedalus
that it is possible.
I don't care what they say, i KNOW it's possible.
I know i can avoid the asteroids. And they know it too.
Bunch of cowards. They even named the project \"Icarus\"
and still they don't dare to fly high.
Seems like they didn't even understand
what the old tale is all about.
I will show them.
After today nobody will doubt me ever again..."""

var WriteLetter = false
var TextPos = 0
var TimerStarted = false

func _ready():
	$Black/Tween.interpolate_property($Black, "modulate", Color(0.0, 0.0, 0.0, 1.0), Color(0.0, 0.0, 0.0, 0.0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Black/Tween.start()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		NextScene()
	elif event.is_action_pressed("ui_cancel"):
		SceneChanger.EndGame()

func _on_Tween_tween_all_completed():
	$Text/Timer.start()

func _on_Timer_timeout():
	if WriteLetter:
		WriteLetter = false
		$Text.text = $Text.text.substr(0, $Text.text.length() - 1) + Text.substr(TextPos, 1)
		TextPos += 1
		if TextPos > Text.length() and not TimerStarted:
			TimerStarted = true
			$StartTimer.start()
	else:
		WriteLetter = true
		$Text.text += "ß"
		if TextPos < Text.length():
			$AudioStreamPlayer.play()

func _on_StartTimer_timeout():
	NextScene()

func NextScene():
	SceneChanger.ChangeScene("res://Scenes/Instructions.tscn")
