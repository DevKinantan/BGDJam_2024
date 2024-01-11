extends Area2D


func _on_body_entered(body):
	if body.name == "Player":
		body.velocity.y += -400
		body.velocity.x = 200
		if body.get_node("BodySprite").flip_h:
			body.velocity.x *= -1
