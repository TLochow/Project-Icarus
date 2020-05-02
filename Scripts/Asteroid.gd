extends RigidBody2D

var EXPLOSIONSCENE = preload("res://Scenes/Explosion.tscn")

var Rotation

signal Destroyed
signal ExtraPoints(points, text, pos)

var IsCloseToPlayer = false
var CloseCallPoints = 0

var TimeOnScreen = 0.0
var TimeOnScreenPoints = 0

func _ready():
	$Sprite.frame = 12 + randi() % 5
	Rotation = rand_range(-0.5, 0.5)

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
		
		if IsOnScreen(pos):
			TimeOnScreen += delta
			if TimeOnScreen > 5.0:
				var timePoints = int(TimeOnScreen) * 5
				if timePoints != TimeOnScreenPoints:
					TimeOnScreenPoints = timePoints
					$JugglingPoints.visible = true
					$JugglingPoints.text = "Juggling: " + str(TimeOnScreenPoints)
				var labelSize = $JugglingPoints.get_size()
				var labelPos = (gravityDirection * labelSize) - (labelSize * 0.5)
				$JugglingPoints.set_position(labelPos)
		else:
			TimeOnScreen = 0.0
			$JugglingPoints.visible = false
			JugglingCashOut()
		
		$Sprite.rotate(Rotation)
		update()

func _draw():
	if TimeOnScreen > 5.0:
		var labelSize = $JugglingPoints.get_size()
		var labelPos = $JugglingPoints.get_position()
		draw_line(labelPos + Vector2(0.0, labelSize.y), labelPos + labelSize, Color(0, 0, 0, 1), 2.0)
		if labelPos.x < 0.0:
			draw_line(labelPos + labelSize, Vector2(0.0, 0.0), Color(0, 0, 0, 1), 2.0)
		else:
			draw_line(labelPos + Vector2(0.0, labelSize.y), Vector2(0.0, 0.0), Color(0, 0, 0, 1), 2.0)

func JugglingCashOut():
	if TimeOnScreenPoints > 0:
		emit_signal("ExtraPoints", TimeOnScreenPoints, "Juggling: +" + str(TimeOnScreenPoints), $JugglingPoints.get_global_position())
		TimeOnScreenPoints = 0

func _on_CollisionArea_body_entered(body):
	if body != self:
		JugglingCashOut()
		var explosion = EXPLOSIONSCENE.instance()
		explosion.set_position(get_position())
		get_tree().get_root().add_child(explosion)
		emit_signal("Destroyed")
		queue_free()

func IsOnScreen(pos):
	return pos.x > 0.0 and pos.x < 1024.0 and pos.y > 0.0 and pos.y < 600.0
