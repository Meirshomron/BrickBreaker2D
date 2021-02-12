extends Node2D

onready var view_width = get_viewport().get_visible_rect().size.x
onready var view_height = get_viewport().get_visible_rect().size.y
onready var paddle_half_height = get_node("Paddle_UI/CollisionShape2D").shape.get_extents().y
onready var paddle_half_width = get_node("Paddle_UI/CollisionShape2D").shape.get_extents().x
onready var paddleUI = $Paddle_UI
onready var powerup_handler = $Powerups_Handler

var speed = 40
var acceleration = 0

var is_init
var powerup_timer
var is_movement_enabled


func _ready():
	is_init = false


func set_start_pos():
	# Initial position.
	var offset_from_ground = 10
	paddleUI.position.y = view_height - paddle_half_height - offset_from_ground
	paddleUI.position.x = view_width / 2


func init():
	is_init = true
	is_movement_enabled = false
	powerup_handler.clear()
	set_start_pos()


func _input(event):
	if is_init and is_movement_enabled:
		# Handle mobile paddle movement.
		if event is InputEventScreenDrag:
			paddleUI.position.x = clamp(event.position.x, paddle_half_width, view_width - paddle_half_width)


func _physics_process(delta):
	if not is_init:
		return
		
	# Move as long as the key/button is pressed, the longer pressed = the faster it moves.
	if Input.is_action_pressed("ui_right"):
		acceleration += delta
		paddleUI.position.x = clamp(paddleUI.position.x + speed * acceleration, paddle_half_width * paddleUI.scale.x, view_width - (paddle_half_width * paddleUI.scale.x))
	if Input.is_action_pressed("ui_left"):
		acceleration += delta
		paddleUI.position.x = clamp(paddleUI.position.x - speed * acceleration, paddle_half_width * paddleUI.scale.x, view_width - (paddle_half_width * paddleUI.scale.x))
	if Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left"):
		acceleration = 0 


func get_position():
	return paddleUI.position


func get_half_height():
	return paddle_half_height

 
func _on_Paddle_area_entered(area):
	if area.is_in_group("Powerup"):
		SignalsManager.emit_signal("power_up_collected", area.get_instance_id())


func disable_paddle_movement():
	is_movement_enabled = false


func enable_paddle_movement():
	is_movement_enabled = true
