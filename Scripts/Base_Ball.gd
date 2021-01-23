extends Node2D

onready var view_width = get_viewport().get_visible_rect().size.x
onready var view_height = get_viewport().get_visible_rect().size.y
onready var root = owner

export var speed = 300

var ball_radius
var direction
var aim_area
var is_enable_physics
var is_hit_floor


func init():
	print("base_ball:init")
	
	direction = Vector2.RIGHT
	root.rotation = 0
	is_hit_floor = false
	is_enable_physics = true
	ball_radius = root.get_node("CollisionShape2D").shape.radius
	aim_area = root.get_node("aim_area")
	aim_area.set_visible(true)


func _physics_process(delta):
	
	if not is_enable_physics:
		return
		
	if is_hit_floor:
		return
	
	root.position += direction * speed * delta
	root.rotation = direction.angle()
	
	# Ceiling.
	if root.position.y < ball_radius:
		direction.y = -direction.y
	
	# Walls.
	if root.position.x < ball_radius or root.position.x > (view_width - ball_radius):
		direction.x = -direction.x
	
	# Floor.
	if root.position.y > (view_height - ball_radius):
		print("ball out of screen")
		is_hit_floor = true
		root.on_ball_out_of_bounds()


func _on_Ball_area_entered(area):
	if not is_enable_physics:
		return
	
	# If we're hiting a brick on its sides then flip the x direction, otherwise we're hitting the brick from the top/bottom.
	if area.is_in_group("Brick"):
		root.on_ball_hit_brick(area)
		if is_hit_sides(area):
			direction.x = -direction.x
			print("hit sides")
		else:
			direction.y = -direction.y
			print("hit up/down")
		
	# If we're hiting a stone on its sides then flip the x direction, otherwise we're hitting the stone from the top/bottom.
	elif area.is_in_group("Stone"):
		if is_hit_sides(area):
			direction.x = -direction.x
		else:
			direction.y = -direction.y
			
	elif area.is_in_group("Paddle"):
		on_hit_paddle(area)


func is_hit_sides(area):
	var hit_half_height = area.get_node("CollisionShape2D").shape.get_extents().y
	var hit_half_width = area.get_node("CollisionShape2D").shape.get_extents().x
	return (root.global_position.x <= (area.global_position.x - hit_half_width) or root.global_position.x >= (area.global_position.x + hit_half_width)) and (root.global_position.y <= (area.global_position.y + hit_half_height) and root.global_position.y >= (area.global_position.y - hit_half_height))


func on_hit_paddle(area):
	var hit_half_height = area.get_node("CollisionShape2D").shape.get_extents().y
	var hit_half_width = area.get_node("CollisionShape2D").shape.get_extents().x
	if root.global_position.y <= (area.global_position.y - hit_half_height):
		# Set the ball angle in according to the position hit on the paddle. 
		# norm = [-1, 1] where 1 is when the ball hit the left edge and -1 when hitting the right edge and we map this to bounce.
		# bounce = [-75, 75] the degree of ball according to position hit on the paddle in this range.
		var rel = area.global_position.x - root.position.x
		var norm = rel / (hit_half_width * 2)
		var bounce = norm * (5 * PI / 12)
		direction = Vector2(-sin(bounce), -cos(bounce))


# if the direction is (0,-1 or 1) then the ball can be hitting 2 bricks at once so we offset the ball a bit randomly. 
func auto_corret_direction():
	var direction_abs_y = abs(direction.y) 
	if direction.x > -0.02 and direction.x < 0.02 and direction_abs_y > 0.98 and direction_abs_y < 1.02:
		var offset = rand_range(-0.1, 0.1)
		direction.x += offset


func set_to_paddle_pos(paddle_pos, paddle_half_width):
	root.position = Vector2(paddle_pos.x, paddle_pos.y - (ball_radius + paddle_half_width))


func start():
	direction = direction.rotated(aim_area.rotation)
	auto_corret_direction()
	aim_area.set_visible(false)
	enable()


func disable():
	is_enable_physics = false


func enable():
	is_enable_physics = true
