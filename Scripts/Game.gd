extends Node2D

onready var ball_controller = $BallController
onready var paddle_controller = $PaddleController
onready var HUD = $HUD

var is_ball_released = false
var is_level_started = false
var is_game_started = false
var is_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalsManager.connect("game_over", self, "on_game_over")
	SignalsManager.connect("game_completed", self, "on_game_completed")
	SignalsManager.connect("start_level", self, "on_start_level")
	SignalsManager.connect("level_completed", self, "on_level_completed")
	SignalsManager.connect("increase_user_life", self, "increase_life")
	SignalsManager.connect("decrease_user_life", self, "decrease_life")
	SignalsManager.connect("player_hit_brick", self, "on_player_hit_brick")
	show_start_level_ui()
	HUD.hide_ui()


func show_start_level_ui():
	print("Game: show_start_level_ui")
	is_level_started = false
	HUD.hide_buttons()
	HUD.show_start_level_ui()
	ball_controller.disable_balls()
	paddle_controller.disable_paddle_movement()
	paddle_controller.clear()
	PowerupsManager.release_all_powerups()


func on_start_level():
	print("Game: on_start_level")
	is_ball_released = false
	is_level_started = true
	paddle_controller.init()
	ball_controller.init()
	HUD.show_buttons()
	LevelsManager.set_current_level()
	if not is_game_started:
		on_start_game()


func on_start_game():
	print("Game: on_start_game")
	UserProgressManager.init()
	HUD.show_ui()
	is_game_started = true
	is_pressed = false


func set_ball_to_paddle_pos():
	var paddle_pos = paddle_controller.get_position()
	var paddle_half_height = paddle_controller.get_half_height()
	ball_controller.set_to_paddle_pos(paddle_pos, paddle_half_height)


func _input(event):
	if is_level_started and not is_ball_released:
		# Fix for pressing the 'start' button wont start the ball but only after another press and release.		
		if event is InputEventScreenTouch and event.is_pressed():
			is_pressed = true
		
		# Handle aiming and releasing the ball in both pc and mobile.
		if Input.is_action_pressed("ui_select") or (is_pressed and event is InputEventScreenTouch and not event.is_pressed()):
			set_ball_to_paddle_pos()
			ball_controller.start_ball()
			paddle_controller.enable_paddle_movement()
			is_ball_released = true


func _physics_process(_delta):
	if is_level_started and not is_ball_released:
		set_ball_to_paddle_pos()


func increase_life():
	UserProgressManager.increase_life()


func decrease_life():
	print("Game: decrease_life")
	var is_game_over = UserProgressManager.decrease_life()
	PowerupsManager.release_all_powerups()
	if not is_game_over:
		is_ball_released = false
		paddle_controller.init()
		ball_controller.init()
		set_ball_to_paddle_pos()


func on_player_hit_brick(hit_id):
	if is_level_started and is_ball_released:
		PowerupsManager.on_player_hit_brick(hit_id)
		BricksManager.on_player_hit_brick(hit_id)


func on_game_over():
	print("Game: on_game_over")
	UserProgressManager.on_game_over()
	LevelsManager.on_game_over()
	is_game_started = false
	show_start_level_ui()


func on_level_completed():
	print("Game: on_level_completed")
	LevelsManager.on_current_level_completed()
	show_start_level_ui()


func on_game_completed():
	print("Game Over!")
