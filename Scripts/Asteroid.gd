extends RigidBody2D

var EXPLOSIONSCENE = preload("res://Scenes/Explosion.tscn")

signal Destroyed
signal ExtraPoints(points, text, pos)

var IsCloseToPlayer = false
var CloseCallPoints = 0

func _ready():
	$Sprite.frame = 12 + randi() % 5
	angular_velocity = rand_range(-30.0, 30.0)

func _physics_process(delta):
	var player = get_tree().get_nodes_in_group("Player")
	if player.size() > 0:
		var playerPos = player[0].get_position()
		var pos = get_position()
		
		var directionToPlayer = playerPos - pos
		var squareDistance = clamp(directionToPlayer.length_squared() * 0.000001, 0.1, 0.8)
		var gravityDirection = directionToPlayer.normalized()
		var gravityForce = gravityDirection * 2.0 / squareDistance
		linear_velocity += gravityForce
		
		var distanceToPlayer = pos.distance_to(playerPos)
		if distanceToPlayer < 50.0 and not IsCloseToPlayer:
			IsCloseToPlayer = true
			var speed = linear_velocity.length()
			if speed >= 1000.0:
				CloseCallPoints = int(speed * 0.001) * 10
		elif distanceToPlayer > 60.0:
			IsCloseToPlayer = false
			if CloseCallPoints > 0:
				emit_signal("ExtraPoints", CloseCallPoints, "Close Call: +" + str(CloseCallPoints), pos)
				CloseCallPoints = 0

func _on_CollisionArea_body_entered(body):
	if body != self:
		var explosion = EXPLOSIONSCENE.instance()
		explosion.set_position(get_position())
		get_tree().get_root().add_child(explosion)
		emit_signal("Destroyed")
		queue_free()
