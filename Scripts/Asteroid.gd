extends RigidBody2D

var Rotation

signal Destroyed(pos)
signal ExtraPoints(points, text, pos)

var Destroyed = false

var IsCloseToPlayer = false
var CloseCallPoints = 0

var TimeOnScreen = 0.0
var TimeOnScreenPoints = 0

func _ready():
	$Sprite.frame = 12 + randi() % 5
	Rotation = rand_range(-40.0, 40.0)

func _physics_process(delta):
	var player = get_tree().get_nodes_in_group("Player")
	if player.size() > 0:
		var playerPos = player[0].get_position()
		var pos = get_position()
		
		var directionToPlayer = playerPos - pos
		var squareDistance = clamp(directionToPlayer.length_squared() * 0.000001, 0.1, 0.8)
		var gravityDirection = directionToPlayer.normalized()
		var gravityForce = gravityDirection * 2.0 / squareDistance
		linear_velocity += gravityForce * 50.0 * delta
		
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
		
		if IsOnScreen(pos):
			TimeOnScreen += delta
			if TimeOnScreen > 5.0:
				var timePoints = int(TimeOnScreen) * 5
				if timePoints != TimeOnScreenPoints:
					TimeOnScreenPoints = timePoints
					$JugglingPoints.text = "Juggling: " + str(TimeOnScreenPoints)
				var labelSize = $JugglingPoints.get_size()
				var labelPos = (gravityDirection * labelSize) - (labelSize * 0.5)
				$JugglingPoints.set_position(labelPos)
		else:
			TimeOnScreen = 0.0
			JugglingCashOut()
		
		$Sprite.rotate(Rotation * delta)

func JugglingCashOut():
	if TimeOnScreenPoints > 0:
		emit_signal("ExtraPoints", TimeOnScreenPoints, "Juggling: +" + str(TimeOnScreenPoints), $JugglingPoints.get_global_position())
		TimeOnScreenPoints = 0

func _on_CollisionArea_body_entered(body):
	if body != self:
		Destroy()
		body.Destroy()

func Destroy():
	if not Destroyed:
		Destroyed = true
		JugglingCashOut()
		emit_signal("Destroyed", get_position())
		call_deferred("queue_free")

func IsOnScreen(pos):
	return pos.x > 0.0 and pos.x < 1024.0 and pos.y > 0.0 and pos.y < 600.0
