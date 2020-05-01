extends Particles2D

func _ready():
	emitting = true
	$AudioStreamPlayer.play()

func _on_Timer_timeout():
	queue_free()
