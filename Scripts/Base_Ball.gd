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
	handle_boundaries()


func handle_boundaries():
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
	
	if area.is_in_group("Brick"):
		root.on_ball_hit_brick(area)
		on_hit_obj(area)
	elif area.is_in_group("Stone"):
		on_hit_obj(area)
	elif area.is_in_group("Paddle"):
		on_hit_paddle(area)


# If we're hiting a stone/brick on its sides then flip the x direction, otherwise we're hitting the from the top/bottom and flip the y direction..
func on_hit_obj(area):
	var hit_half_height = area.get_node("CollisionShape2D").shape.get_extents().y
	var hit_half_width = area.get_node("CollisionShape2D").shape.get_extents().x
	
	if is_hit_left(hit_half_height, hit_half_width, area):
		direction.x = -abs(direction.x)
	elif is_hit_right(hit_half_height, hit_half_width, area):
		direction.x = abs(direction.x)
	elif is_hit_bottom(hit_half_height, area):
		direction.y = abs(direction.y)
	elif is_hit_top(hit_half_height, area):
		direction.y = -abs(direction.y)


func is_hit_left(hit_half_height, hit_half_width, area):
	return root.global_position.x <= (area.global_position.x - hit_half_width)  and (root.global_position.y <= (area.global_position.y + hit_half_height) and root.global_position.y >= (area.global_position.y - hit_half_height))


func is_hit_right(hit_half_height, hit_half_width, area):
	return root.global_position.x >= (area.global_position.x + hit_half_width) and (root.global_position.y <= (area.global_position.y + hit_half_height) and root.global_position.y >= (area.global_position.y - hit_half_height))


func is_hit_bottom(hit_half_height, area):
	return root.global_position.y > (area.global_position.y + hit_half_height) and root.global_position.y >= (area.global_position.y - hit_half_height)


func is_hit_top(hit_half_height, area):
	return root.global_position.y < (area.global_position.y - hit_half_height)


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


func set_to_paddle_pos(paddle_pos, paddle_half_width):
	root.position = Vector2(paddle_pos.x, paddle_pos.y - (ball_radius + paddle_half_width))


func start():
	set_to_aim_area_direction()
	set_aim_area_visible(false)
	enable()


func get_aim_area():
	return aim_area


func set_to_aim_area_direction():
	direction = direction.rotated(aim_area.rotation)


func set_aim_area_visible(is_visible):
	aim_area.set_visible(is_visible)


func disable():
	is_enable_physics = false


func enable():
	is_enable_physics = true
