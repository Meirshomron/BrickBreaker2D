extends Node2D

onready var ball_controller = $Ball
onready var paddle = $Paddle

export(bool) var start_hold_aim_active = true
var orig_start_hold_aim_active


# Called when the node enters the scene tree for the first time.
func _ready():
	orig_start_hold_aim_active = start_hold_aim_active
	init()


func init():
	# Init LevelsManager, when ready will init the BricksManager and the powerupsManager with the current level.
	LevelsManager.init()
	
	# Init paddle.
	paddle.init()
	paddle.set_start_pos()
	
	# Init ball.
	ball_controller.init()
	set_ball_start_pos()
	start_hold_aim_active = orig_start_hold_aim_active
	ball_controller.disable_ball()
	
	UserProgressManager.init()


func set_ball_start_pos():
	var paddle_pos = paddle.get_position()
	var paddle_half_width = paddle.get_node("CollisionShape2D").shape.get_extents().y
	ball_controller.set_to_paddle_pos(paddle_pos, paddle_half_width)


func _physics_process(_delta):
	if start_hold_aim_active:
		if Input.is_action_pressed("ui_select"):
			ball_controller.start_ball()
			start_hold_aim_active = false
		else:
			set_ball_start_pos()


func _on_ball_out_of_bounds():
	init()


func _on_ball_hit_brick(hit_id):
	PowerupsManager._on_ball_hit_brick(hit_id)
	BricksManager._on_ball_hit_brick(hit_id)
