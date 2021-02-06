extends Node2D

onready var ball_controller = $Ball
onready var paddle = $Paddle

var is_ball_released = false


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalsManager.connect("game_over", self, "on_game_over")
	SignalsManager.connect("level_completed", self, "on_level_completed")
	init()


func init():
	# Init LevelsManager, when ready will init the BricksManager and the powerupsManager with the current level.
	LevelsManager.init()
	UserProgressManager.init()
	paddle.init()
	ball_controller.init()


func set_ball_to_paddle_pos():
	var paddle_pos = paddle.get_position()
	var paddle_half_width = paddle.get_node("CollisionShape2D").shape.get_extents().y
	ball_controller.set_to_paddle_pos(paddle_pos, paddle_half_width)


func _input(event):
	if not is_ball_released:
		# Handle aiming and releasing the ball in both pc and mobile.
		if Input.is_action_pressed("ui_select") or (event is InputEventScreenTouch and not event.is_pressed()):
			ball_controller.start_ball()
			paddle.enable_paddle_movement()
			is_ball_released = true


func _physics_process(_delta):
	if not is_ball_released:
		set_ball_to_paddle_pos()


func _on_ball_out_of_bounds():
	SignalsManager.emit_signal("decrease_user_life")
	paddle.init()
	ball_controller.init()
	is_ball_released = false


func _on_ball_hit_brick(hit_id):
	PowerupsManager._on_ball_hit_brick(hit_id)
	BricksManager._on_ball_hit_brick(hit_id)


func on_game_over():
	init()

func on_level_completed():
	LevelsManager.on_current_level_completed()
	paddle.init()
	ball_controller.init()
	is_ball_released = false
