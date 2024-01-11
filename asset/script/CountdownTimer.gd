extends Label


@export var total_time = 5
@export var countdown = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(countdown)


func _on_timer_timeout():
	countdown -= 1
	text = str(countdown)
	if countdown > 0:
		$Timer.start()
	
	if countdown <= 0:
		countdown = total_time
