extends Sprite2D

@export var cooldown = 1.0
@export var power = 300
@export var direction = Vector2(-1, 0)

var projectile_scn = preload("res://scene/projectile.tscn")


func _ready():
	$AnimationPlayer.play("Shoot", -1, 1/cooldown)


func spawn_projectile():
	var proj_node = projectile_scn.instantiate()
	proj_node.linear_velocity = (power * direction)
	proj_node.power = proj_node.linear_velocity.x
	add_child(proj_node)
