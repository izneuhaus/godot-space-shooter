extends KinematicBody2D

export var move_speed = 50
export var turn_direction = 1
enum PLAYER_CLASS {DEFAULT, SNIPER}
export (PLAYER_CLASS) var player_class

var bullet_limit = 3
var stunned = false


func _ready():
	if player_class == PLAYER_CLASS.SNIPER:
		move_speed = 30


func _physics_process(delta):
	var move_vec = Vector2()

	if !stunned:
		if Input.is_action_pressed("move_left"):
			move_vec.x -= 1
		if Input.is_action_pressed("move_right"):
			move_vec.x += 1
		if Input.is_action_pressed("move_up"):
			get_class_specific_action("move_up", player_class)
		if Input.is_action_pressed("move_down"):
			get_class_specific_action("move_down", player_class)

		if Input.is_action_just_pressed("shoot"):
			var bullet_count = get_tree().get_nodes_in_group("player_bullets").size()

			if bullet_count < bullet_limit:
				$FiringPoint.rotation = rotation
				$FiringPoint.shoot(move_vec.x)


	if move_vec:
		if player_class == PLAYER_CLASS.SNIPER:
			pass
		else:
			$Tween.interpolate_property(
				self, "rotation", rotation,
				turn_direction * (move_vec.x / 2), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN
			)
			$Tween.start()
	else:
		if player_class == PLAYER_CLASS.SNIPER:
			pass
		else:
			$Tween.interpolate_property(
				self, "rotation", rotation,
				0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN
			)
			$Tween.start()

	var collision = move_and_collide(move_vec * delta * move_speed)

	if collision:
		if collision.collider is KinematicBody2D:
			hit()


func hit():
	stunned = true
	$StunCooldown.wait_time = 0.4
	$StunCooldown.start()
	Global.Camera.trauma = 0.4
	yield($StunCooldown, "timeout")
	stunned = false
	# get_tree().paused = true


func _on_Enemy_hit(enemy_body):
	Global.Camera.trauma = 0.2
	var timer = get_tree().create_timer(0.1 * enemy_body.hit_count)
	pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true
	yield(timer, "timeout")
	get_tree().paused = false
	pause_mode = Node.PAUSE_MODE_STOP


func get_class_specific_action(input, pclass):
	if pclass == PLAYER_CLASS.SNIPER:
		if input == "move_up":
			rotate(0.1)
		elif input == "move_down":
			rotate(-0.1)
