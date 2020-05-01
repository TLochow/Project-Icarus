extends RigidBody2D

signal Destroyed

func _physics_process(delta):
	var player = get_tree().get_nodes_in_group("Player")
	if player.size() > 0:
		var playerPos = player[0].get_position()
		var pos = get_position()
		
		var directionToPlayer = playerPos - pos
		var squareDistance = clamp(directionToPlayer.length_squared() * 0.00001, 0.1, 0.8)
		var gravityDirection = directionToPlayer.normalized()
		var gravityForce = gravityDirection * 2.0 / squareDistance
		linear_velocity += gravityForce
