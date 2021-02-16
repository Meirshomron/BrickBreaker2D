extends Node2D

onready var paddle_half_width = get_node("../Paddle_UI/CollisionShape2D").shape.get_extents().x
onready var paddleUI = get_node("../Paddle_UI")
onready var propsContainer = get_node("../Props_Container")
onready var paddle = owner

const BULLET_POOL_SIZE = 20
const BULLET_POOL_PREFIX = "bullet"

# Only support 1 paddle powerup active at a time
var current_powerup_id
var current_powerup_data

var start_paddle_half_width
var start_scale_x
var powerup_timer

var pool_res
var pool


func _ready():
	pool_res = preload("res://Scripts/Object_Pool/Pool.gd")

	start_scale_x = paddleUI.scale.x
	current_powerup_data = {}
	SignalsManager.connect("paddle_power_up_collected", self, "on_powerup_collected")


func on_powerup_collected(powerup_id, powerup_data):
	print("Paddle_Powerups_Handler: on_powerup_collected " + str(powerup_id))
	print(powerup_data)
	
	if current_powerup_id != null:
		powerup_timer.stop()
		powerup_timout()
	
	current_powerup_id = powerup_id
	match powerup_id:
		"paddle_expand":
			set_paddle_scale_x(powerup_data.scale_amount)
			create_powerup_end_timer(powerup_data.timeout)
		"bullets":
			prepare_bullets(powerup_data)
			create_powerup_end_timer(powerup_data.timeout)


func set_paddle_scale_x(scale_val):
	paddleUI.scale.x = scale_val
	if not start_paddle_half_width:
		start_paddle_half_width = paddle_half_width
	paddle_half_width = start_paddle_half_width * paddleUI.scale.x


func prepare_bullets(powerup_data):
	current_powerup_data.bullet_scn = preload("res://Scenes/Bullet.tscn")
	if not pool:
		pool = pool_res.new(BULLET_POOL_SIZE, BULLET_POOL_PREFIX, current_powerup_data.bullet_scn)
		pool.add_to_node(propsContainer)
		pool.connect("killed", self, "_on_pool_killed")
	
	if current_powerup_data.has("spawn_timer"):
		remove_timer(current_powerup_data.spawn_timer)
	current_powerup_data.spawn_timer = Timer.new()
	current_powerup_data.spawn_timer.set_wait_time(powerup_data.interval)
	current_powerup_data.spawn_timer.set_one_shot(false)
	current_powerup_data.spawn_timer.connect("timeout", self, "shoot_bullet")
	add_child(current_powerup_data.spawn_timer)
	current_powerup_data.spawn_timer.start()
#	print("adding bullet powerup_timer " + current_powerup_data.spawn_timer.name )

func _on_pool_killed(target):
	target.hide()
#	print("Currently %d objects alive in pool" % pool.get_alive_size())


func shoot_bullet():
#	print("shoot_bullet")
	var spawn_offset = Vector2(35, -15)
	for n in 2:
		var bullet = pool.get_first_dead()
		if bullet:
			spawn_offset.x *= -1
			bullet.global_position = paddleUI.position + spawn_offset
			bullet.is_active = true
			bullet.show()
		else:
			print("failed creating bulled by pool")
			bullet = pool.get_first_dead()


func create_powerup_end_timer(timeout):
	remove_timer(powerup_timer)
	powerup_timer = Timer.new()
	powerup_timer.set_one_shot(true)
	powerup_timer.autostart = true
	powerup_timer.set_wait_time(timeout)
	powerup_timer.connect("timeout", self, "powerup_timout")
	powerup_timer.start()
	add_child(powerup_timer)


func powerup_timout():
#	print("Paddle_Controller: powerup_timout")
	remove_timer(powerup_timer)
	match current_powerup_id:
		"paddle_expand":
			set_paddle_scale_x(start_scale_x)
		"bullets":
			remove_timer(current_powerup_data.spawn_timer)
	current_powerup_data.clear()
	current_powerup_data = {}
	current_powerup_id = null


func remove_timer(timer):
	if timer:
		timer.stop()
		remove_child(timer)
		timer = null


func clear():
	print("Paddle_Powerups_Handler: clear")
	if current_powerup_id != null:
		powerup_timout()
	if pool:
		pool.kill_all()
