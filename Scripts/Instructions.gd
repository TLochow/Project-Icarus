extends Control

func _input(event):
	if event.is_action_pressed("ui_accept"):
		SceneChanger.ChangeScene("res://Scenes/Main.tscn")
	elif event.is_action_pressed("ui_cancel"):
		SceneChanger.EndGame()
