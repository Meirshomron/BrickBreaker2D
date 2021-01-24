extends "res://Scripts/Base_Ball.gd"


func init():
	.init()
	rotation = deg2rad(-90)

# overrride the Base_ball implementation with an empty one - so our rocket will go through bricks.
func on_hit_obj(area):
	pass

func enable():
	.enable()
	rotation = 0
