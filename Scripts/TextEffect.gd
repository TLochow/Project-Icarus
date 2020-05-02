extends Label

var Text setget SetText

func _ready():
	$AnimationPlayer.play("TextAnimation")

func SetText(newText):
	text = str(newText)

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
