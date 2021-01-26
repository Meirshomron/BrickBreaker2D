extends Area2D

signal ball_out_of_bounds
signal ball_hit_brick

onready var balls_parent = $UI_Container

const ball_types = ["standard_ui", "rocket_ui"]
var start_ball_type = "standard_ui"

var current_ball
var current_ball_type
var current_ball_contdown
var powerup_timer 


func _ready():
	SignalsManager.connect("ball_power_up_collected", self, "on_powerup_collected")


func init():
	print("Ball_Controller: init")
	if powerup_timer:
		powerup_timer.stop()
		remove_child(powerup_timer)
		powerup_timer = null
	current_ball_type = start_ball_type
	init_ball()


func set_to_paddle_pos(paddle_pos, paddle_half_width):
	current_ball.set_to_paddle_pos(paddle_pos, paddle_half_width)


func init_ball():
	print("Ball_Controller: init_ball current = " + str(current_ball_type))
	current_ball = balls_parent.get_node(current_ball_type)
	current_ball.set_visible(true)
	current_ball.init()


func disable_ball():
	current_ball.disable()


func enable_ball():
	current_ball.enable()


func start_ball():
	current_ball.start()


func change_ball_type(new_ball_type):
	print("Ball_Controller: change_ball_type")
	disable_ball()
	var previous_direction = current_ball.direction
	var is_previous_aim_area_visible = current_ball.get_aim_area().is_visible()
	current_ball.set_visible(false)
	current_ball_type = new_ball_type
	init_ball()
	# if the aim is active then the ball changed before the ball was released.
	# can happen if we lose a life and then collect a ball powerup before releasing the ball again.
	if not is_previous_aim_area_visible:
		enable_ball()
		
	current_ball.set_aim_area_visible(is_previous_aim_area_visible)
	current_ball.direction = previous_direction


func _on_Ball_area_entered(area):
	current_ball._on_Ball_area_entered(area)


func on_ball_hit_brick(area):
	emit_signal("ball_hit_brick", area.get_instance_id())


func on_ball_out_of_bounds():
	emit_signal("ball_out_of_bounds")


func on_powerup_collected(powerup_id, powerup_data):
	print("Ball_controller: on_powerup_collected")
	print(powerup_data)
	print(powerup_id)
	
	match powerup_id:
		"powerup_rocket":
			change_ball_type("rocket_ui")
			create_powerup_end_timer(powerup_data.timeout)


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
