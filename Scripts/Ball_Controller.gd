extends Node2D

onready var ballsContainer = $Balls_Container
onready var aim_area = $aim_area

const ball_types = ["Standard_Ball", "Rocket_Ball"]
var start_ball_type = "Standard_Ball"

var current_ball
var current_ball_res
var current_ball_type
var powerup_timer 


func _ready():
	current_ball_res = load("res://Scenes/Balls/" + start_ball_type + ".tscn")
	SignalsManager.connect("ball_power_up_collected", self, "on_powerup_collected")
	SignalsManager.connect("ball_hit_floor", self, "on_ball_hit_floor")
	aim_area.set_visible(false)

func init():
	print("Ball_Controller: init")
	if powerup_timer:
		powerup_timer.stop()
		remove_child(powerup_timer)
		powerup_timer = null
	current_ball_type = start_ball_type
	aim_area.set_visible(true)
	if current_ball:
		release_all_balls()
	init_ball()


func init_ball():
	print("Ball_Controller: init_ball current = " + str(current_ball_type))
	current_ball = current_ball_res.instance()
	ballsContainer.add_child(current_ball, true)
	current_ball.init()
	disable_balls()


func set_to_paddle_pos(paddle_pos, paddle_half_height):
	current_ball.set_to_paddle_pos(paddle_pos, paddle_half_height)
	aim_area.position = current_ball.position


func disable_balls():
	for ball in ballsContainer.get_children():
		ball.disable()


func enable_balls():
	for ball in ballsContainer.get_children():
		current_ball.enable()


func release_all_balls():
	for ball in ballsContainer.get_children():
		ball.queue_free()


func start_ball():
	aim_area.set_visible(false)
	current_ball.start(aim_area.rotation)


func on_ball_hit_floor(ball_id):
		var num_of_balls = ballsContainer.get_child_count()
		if num_of_balls == 1:
			SignalsManager.emit_signal("decrease_user_life")
		else:
			var ball_instance = instance_from_id(ball_id) 
			var current_ball_id = current_ball.get_instance_id()
			ball_instance.queue_free()
			if current_ball_id == ball_id:
				for i in num_of_balls:
					current_ball = ballsContainer.get_child(i)
					current_ball_id = current_ball.get_instance_id()
					if current_ball_id != ball_id:
						break


# ----------- Powerups ----------- #
func on_powerup_collected(powerup_id, powerup_data):
	print("Ball_controller: on_powerup_collected " + str(powerup_id))
	print(powerup_data)
	
	# edge case of collecting a powerup after reomiving the current ball and before creating the new ball. 
	if not current_ball:
		return
	
	match powerup_id:
		"powerup_rocket":
			change_ball_type("Rocket_Ball")
			create_powerup_end_timer(powerup_data.timeout)
		"multiple_balls":
			create_multiple_balls(powerup_data.amount)


func change_ball_type(new_ball_type):
	print("Ball_Controller: change_ball_type")
	disable_balls()
	current_ball_type = new_ball_type
	current_ball_res = load("res://Scenes/Balls/" + current_ball_type + ".tscn")
	var new_ball
	for prev_ball in ballsContainer.get_children():
		var previous_direction = prev_ball.direction
		var previous_position = prev_ball.position
		prev_ball.queue_free()
		
		new_ball = current_ball_res.instance()
		ballsContainer.add_child(new_ball, true)
		new_ball.init()
		new_ball.direction = previous_direction
		new_ball.position = previous_position
	current_ball = new_ball


func create_multiple_balls(amount):
	for i in amount:
		var extra_ball = current_ball_res.instance()
		ballsContainer.add_child(extra_ball, true)
		extra_ball.init()
		extra_ball.position = current_ball.position
		extra_ball.start(current_ball.rotation + rand_range(-0.3, 0.3))


func create_powerup_end_timer(timeout):
	if powerup_timer:
		powerup_timer.stop()
		remove_child(powerup_timer)
	
	powerup_timer = Timer.new()
	powerup_timer.set_one_shot(true)
	powerup_timer.autostart = true
	powerup_timer.set_wait_time(timeout)
	powerup_timer.connect("timeout", self, "powerup_timout")
	powerup_timer.start()
	add_child(powerup_timer)


func powerup_timout():
	print("Ball_Controller: powerup_timout")
	remove_child(powerup_timer)
	powerup_timer = null
	change_ball_type(start_ball_type)
