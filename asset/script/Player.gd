extends CharacterBody2D


@export var SPEED = 150.0
@export var JUMP_VELOCITY = -400.0

enum PlayerState{
	MOVE,
	PRE_JUMP,
	JUMP,
	DEAD,
	KNOCK_BACK
}

var is_finish = false
var jump_power = 0.1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var state = PlayerState.MOVE

var jump_effect_scn = preload("res://scene/jump_effect.tscn")


func set_jump_power(power:float):
	jump_power = power


func set_flip_character(val):
	$BodySprite.flip_h = val
	$KeySprite.flip_h = val
	$KeySprite.offset = Vector2(12, 0) if val else Vector2(0, 0)


func respawn():
	global_position = Vector2(60, 915)
	state = PlayerState.MOVE


func move_state():
	if velocity.x == 0.0:
		if $BodyAnimation.current_animation != "Idle":
			$BodyAnimation.stop()
		$BodyAnimation.play("Idle")
	else:
		if $BodyAnimation.current_animation != "Walk":
			$BodyAnimation.stop()
		$BodyAnimation.play("Walk")

		if $BombTimer.is_stopped() and not is_finish:
			$BombTimer.start()
		
		if $CanvasLayer/CountdownTimer/Timer.is_stopped():
			if $CanvasLayer/CountdownTimer.countdown <= 0:
				$CanvasLayer/CountdownTimer.countdown = $CanvasLayer/CountdownTimer.total_time
			$CanvasLayer/CountdownTimer/Timer.start()


func pre_jump_state():
	pass


func jump_state(delta):
	if $BodyAnimation.current_animation != "Jump":
		$BodyAnimation.stop()
	$BodyAnimation.play("Jump")
		
	velocity.y += gravity * delta
	
	#if velocity.y != 0.0:
		#velocity.x = 100
		#if $BodySprite.flip_h:
			#velocity.x *= -1
	
	if is_on_wall():
		velocity.x = SPEED * 0.8
		if not $BodySprite.flip_h:
			velocity.x *= -1
		set_flip_character(not $BodySprite.flip_h)

		velocity.y += velocity.y * 0.2
	
	if is_on_floor():
		velocity.x = 0.0
		state = PlayerState.MOVE


func dead_state():
	pass


func knock_back_state():
	if velocity.is_zero_approx():
		state = PlayerState.MOVE


func _physics_process(delta):
	if not is_on_floor():
		state = PlayerState.JUMP
	
	if velocity == Vector2.ZERO and (state == PlayerState.MOVE or state == PlayerState.PRE_JUMP) and not $BombTimer.is_stopped():
		$KeyAnimation.play("Spin")
		get_tree().paused = true
		#get_parent().modulate = Color(0.0, 0.7, 1.0)
		if not get_parent().modulate.is_equal_approx(Color(0.7, 0.5, 0.2)):
			get_parent().get_node("FreezeAnimation").play("Freeze")
		$BombTimer.paused = false
		$CanvasLayer/CountdownTimer/Timer.paused = false
		$CanvasLayer/CountdownTimer.visible = true
		if not $Clock.playing:
			$Clock.play()
		#print($BombTimer.time_left)
	else:
		$KeyAnimation.pause()
		get_tree().paused = false
		if get_parent().modulate != Color(1.0, 1.0, 1.0):
			get_parent().get_node("FreezeAnimation").play_backwards("Freeze")
		#get_parent().modulate = Color(1.0, 1.0, 1.0)
		$BombTimer.paused = true
		$CanvasLayer/CountdownTimer/Timer.paused = true
		$CanvasLayer/CountdownTimer.visible = false
		if $Clock.playing:
			$Clock.stop()

	match state:
		PlayerState.MOVE:
			move_state()
		PlayerState.PRE_JUMP:
			pre_jump_state()
		PlayerState.JUMP:
			jump_state(delta)
		PlayerState.DEAD:
			dead_state()
		PlayerState.KNOCK_BACK:
			knock_back_state()

	move_and_slide()
	#print(velocity)


func _input(_event):
	if state == PlayerState.MOVE:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if velocity.x != 0.0:
			set_flip_character(velocity.x < 0)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and state != PlayerState.KNOCK_BACK and state != PlayerState.DEAD:
		if $BodyAnimation.current_animation != "PreJump":
			$BodyAnimation.stop()
		$BodyAnimation.play("PreJump")
		set_jump_power(0.2)
		velocity.x = 0.0
		state = PlayerState.PRE_JUMP

	if Input.is_action_just_released("ui_accept") and state == PlayerState.PRE_JUMP:
		velocity.y = JUMP_VELOCITY * jump_power
		velocity.x = SPEED if not $BodySprite.flip_h else -SPEED
		
		var jump_effect = jump_effect_scn.instantiate()
		jump_effect.global_position = global_position
		jump_effect.global_position.y -= 7
		get_parent().add_child(jump_effect)
		$Jump.play()


func _on_bomb_timer_timeout():
	state = PlayerState.DEAD
	if $BodyAnimation.current_animation != "Dead":
		$BodyAnimation.stop()
	$BodyAnimation.play("Dead")


func _on_finish_area_body_entered(body):
	if body.name == "Player":
		if not body.get_node("BombTimer").is_stopped():
			body.get_node("BombTimer").stop()
			body.is_finish = true
