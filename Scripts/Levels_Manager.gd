extends Node

var current_level_index

func _ready():
	current_level_index = 0


func init():
	print("Levels_Manager: init")
	set_current_level()


func on_current_level_completed():
	current_level_index += 1
	set_current_level()

func set_current_level():
	print("Levels_Manager: setting level " + str(current_level_index))
	var res = load_level_data(current_level_index)
	BricksManager.init_level(res.bricks)
	PowerupsManager.init_level(res.powerups)

func load_level_data(level):
	var res = load("res://Levels_Data/level" + str(level) + ".tres")
	if res:
		print(res.bricks)
		print("-------")
		print(res.powerups)
		return res
	else:
		printerr("Missing Levels_Data for level = " + str(level))
