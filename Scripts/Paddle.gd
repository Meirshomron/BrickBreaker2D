extends Area2D

onready var view_width = get_viewport().get_visible_rect().size.x
onready var view_height = get_viewport().get_visible_rect().size.y
onready var paddle_half_height = $CollisionShape2D.shape.get_extents().y
onready var paddle_half_width = $CollisionShape2D.shape.get_extents().x

var speed = 40
var acceleration = 0
var start_scale_x
var is_init
var powerup_timer
var start_paddle_half_width
var is_movement_enabled


func _ready():
	is_init = false
	start_scale_x = scale.x
	SignalsManager.connect("paddle_power_up_collected", self, "on_powerup_collected")


func set_start_pos():
	# Initial position.
	var offset_from_ground = 10
	position.y = view_height - paddle_half_height - offset_from_ground
	position.x = view_width / 2

func init():
	is_init = true
	is_movement_enabled = false
	if powerup_timer:
		powerup_timout()
	set_start_pos()


func _input(event):
	if is_init and is_movement_enabled:
		# Handle mobile paddle movement.
		if event is InputEventScreenDrag:
			position.x = clamp(event.position.x, paddle_half_width, view_width - paddle_half_width)


func _physics_process(delta):
	if not is_init:
		return
		
	# Move as long as the key/button is pressed, the longer pressed = the faster it moves.
	if Input.is_action_pressed("ui_right"):
		acceleration += delta
		position.x = clamp(position.x + speed * acceleration, paddle_half_width, view_width - paddle_half_width)
	if Input.is_action_pressed("ui_left"):
		acceleration += delta
		position.x = clamp(position.x - speed * acceleration, paddle_half_width, view_width - paddle_half_width)
	if Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left"):
		acceleration = 0 


func get_position():
	return position


func _on_Paddle_area_entered(area):
	if area.is_in_group("Powerup"):
		SignalsManager.emit_signal("power_up_collected", area.get_instance_id())


func on_powerup_collected(powerup_id, powerup_data):
	print("Paddle: on_powerup_collected")
	print(powerup_data)
	print(powerup_id)
	
	match powerup_id:
		"paddle_expand":
			set_paddle_scale_x(powerup_data.scale_amount)
			create_powerup_end_timer(powerup_data.timeout)


func set_paddle_scale_x(scale_val):
	scale.x = scale_val
	if not start_paddle_half_width:
		start_paddle_half_width = paddle_half_width
	paddle_half_width = start_paddle_half_width * scale.x


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
	print("Paddle: powerup_timout")
	remove_child(powerup_timer)
	powerup_timer = null
	set_paddle_scale_x(start_scale_x)


func disable_paddle_movement():
	is_movement_enabled = false


func enable_paddle_movement():
	is_movement_enabled = true
