extends RigidBody2D


var power = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if power < 0:
		$Sprite2D.rotation_degrees = 180


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if abs(linear_velocity.x) < 5.0 :
		queue_free()


func _on_body_entered(body):
	if body.name == "Player":
		if body.state != body.PlayerState.DEAD:
			body.velocity.x = power
			body.state = body.PlayerState.KNOCK_BACK
			body.get_node("Hit").play()
			queue_free()
