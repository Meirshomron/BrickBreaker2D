extends "res://Scripts/Base_Ball.gd"


func init():
	.init()
	rotation = deg2rad(-90)

func _on_Ball_area_entered(area):
	if not is_enable_physics:
		return

	# If we're hiting a brick on its sides then flip the x direction, otherwise we're hitting the brick from the top/bottom.
	if area.is_in_group("Brick"):
		root.on_ball_hit_brick(area)
	# If we're hiting a stone on its sides then flip the x direction, otherwise we're hitting the stone from the top/bottom.
	elif area.is_in_group("Stone"):
		if is_hit_sides(area):
			direction.x = -direction.x
		else:
			direction.y = -direction.y
			
	elif area.is_in_group("Paddle"):
		on_hit_paddle(area)


func enable():
	.enable()
	rotation = 0
