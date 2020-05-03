extends Particles2D

func Destroy():
	emitting = false
	$DespawnTimer.start()

func _on_DespawnTimer_timeout():
	queue_free()
