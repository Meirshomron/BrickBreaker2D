extends Node2D

onready var ball_controller = $BallController
onready var paddle_controller = $PaddleController

var is_ball_released = false


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalsManager.connect("game_over", self, "on_game_over")
	SignalsManager.connect("level_completed", self, "on_level_completed")
	SignalsManager.connect("player_hit_brick", self, "on_player_hit_brick")
	SignalsManager.connect("ball_out_of_bounds", self, "on_ball_out_of_bounds")
	init()


func init():
	# Init LevelsManager, when ready will init the BricksManager and the powerupsManager with the current level.
	LevelsManager.init()
	UserProgressManager.init()
	paddle_controller.init()
	ball_controller.init()


func set_ball_to_paddle_pos():
	var paddle_pos = paddle_controller.get_position()
	var paddle_half_height = paddle_controller.get_half_height()
	ball_controller.set_to_paddle_pos(paddle_pos, paddle_half_height)


func _input(event):
	if not is_ball_released:
		# Handle aiming and releasing the ball in both pc and mobile.
		if Input.is_action_pressed("ui_select") or (event is InputEventScreenTouch and not event.is_pressed()):
			ball_controller.start_ball()
			paddle_controller.enable_paddle_movement()
			is_ball_released = true


func _physics_process(_delta):
	if not is_ball_released:
		set_ball_to_paddle_pos()


func on_ball_out_of_bounds():
	SignalsManager.emit_signal("decrease_user_life")
	paddle_controller.init()
	ball_controller.init()
	is_ball_released = false


func on_player_hit_brick(hit_id):
	PowerupsManager.on_player_hit_brick(hit_id)
	BricksManager.on_player_hit_brick(hit_id)


func on_game_over():
	init()


func on_level_completed():
	LevelsManager.on_current_level_completed()
	paddle_controller.init()
	ball_controller.init()
	is_ball_released = false
