extends Node2D

onready var settings = $Settings
onready var start_level_ui = $Start_Level_UI
onready var pause = $Pause
onready var score_txt = $Score
onready var lives_parent = $Lives

func hide_buttons():
	settings.hide()
	pause.hide()


func show_buttons():
	settings.show()
	pause.show()


func show_start_level_ui():
	start_level_ui.show()


func hide_ui():
	score_txt.hide()
	lives_parent.hide()


func show_ui():
	score_txt.show()
	lives_parent.show()


func update_ui(score_count, lives_count):
	#score
	score_txt.text = "SCORE: " + str(score_count)
	#lives
	for i in range(1, 4):
		var live_img = lives_parent.get_node("Life_" + str(i))
		if i <= lives_count:
			live_img.set_visible(true)
		else:
			live_img.set_visible(false)

