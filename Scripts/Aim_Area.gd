extends Node2D

var aim_speed 


func _ready():
	aim_speed = deg2rad(5)
	
func _physics_process(_delta):
	var mouse_pos = get_global_mouse_position()
	var angle_to_mouse_pos = get_angle_to(mouse_pos) 

	if abs(angle_to_mouse_pos) > 0.1:
		if angle_to_mouse_pos > 0:
			rotation += aim_speed
		else:
			rotation -= aim_speed
		rotation = deg2rad(clamp(rad2deg(rotation), -155.0, -25.0))
