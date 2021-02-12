extends Node2D

onready var view_width = get_viewport().get_visible_rect().size.x
onready var view_height = get_viewport().get_visible_rect().size.y

export var speed = 340

var ball_radius
var direction
var is_enable_physics
var is_hit_floor


func init():
	print("base_ball:init")
	
	direction = Vector2.RIGHT
	rotation = 0
	is_hit_floor = false
	is_enable_physics = true
	ball_radius = get_node("CollisionShape2D").shape.radius


func _physics_process(delta):
	if not is_enable_physics:
		return
		
	if is_hit_floor:
		return

	position += direction * speed * delta
	rotation = direction.angle()
	handle_boundaries()


func handle_boundaries():
	# Ceiling.
	if position.y < ball_radius:
		direction.y = -direction.y
	
	# Walls.
	if position.x < ball_radius or position.x > (view_width - ball_radius):
		direction.x = -direction.x
	
	# Floor.
	if position.y > (view_height - ball_radius):
		print("ball out of screen")
		is_hit_floor = true
		SignalsManager.emit_signal("ball_hit_floor", get_instance_id())


func _on_Ball_area_entered(area):
	if not is_enable_physics:
		return
	
	if area.is_in_group("Brick"):
		SignalsManager.emit_signal("player_hit_brick", area.get_instance_id())
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
	return position.x <= (area.global_position.x - hit_half_width)  and (position.y <= (area.global_position.y + hit_half_height) and position.y >= (area.global_position.y - hit_half_height))


func is_hit_right(hit_half_height, hit_half_width, area):
	return position.x >= (area.global_position.x + hit_half_width) and (position.y <= (area.global_position.y + hit_half_height) and position.y >= (area.global_position.y - hit_half_height))


func is_hit_bottom(hit_half_height, area):
	return position.y > (area.global_position.y + hit_half_height) and position.y >= (area.global_position.y - hit_half_height)


func is_hit_top(hit_half_height, area):
	return position.y < (area.global_position.y - hit_half_height)


func on_hit_paddle(area):
	var hit_half_height = area.get_node("CollisionShape2D").shape.get_extents().y
	var hit_half_width = area.get_node("CollisionShape2D").shape.get_extents().x
	if position.y <= (area.global_position.y - hit_half_height):
		# Set the ball angle in according to the position hit on the paddle. 
		# norm = [-1, 1] where 1 is when the ball hit the left edge and -1 when hitting the right edge and we map this to bounce.
		# bounce = [-75, 75] the degree of ball according to position hit on the paddle in this range.
		var rel = area.global_position.x - position.x
		var norm = rel / (hit_half_width * 2)
		var bounce = norm * (5 * PI / 12)
		direction = Vector2(-sin(bounce), -cos(bounce))


func set_to_paddle_pos(paddle_pos, paddle_half_height):
	position = Vector2(paddle_pos.x, paddle_pos.y - (ball_radius + paddle_half_height))


func start(start_rotation):
	direction = direction.rotated(start_rotation)
	enable()


func disable():
	is_enable_physics = false


func enable():
	is_enable_physics = true
