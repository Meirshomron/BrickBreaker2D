extends Node2D


var is_settings_open
onready var settings_UI = $Settings_UI

func _ready():
	is_settings_open = false


func _on_settingsButton_button_down():
	print("_on_settingsButton_button_down")
	if is_settings_open:
		return
	is_settings_open = true
	open_settings_UI()


func open_settings_UI():
	settings_UI.show()
	get_tree().paused = true
	var highscore = UserProgressManager.get_highscore()
	var highscore_txt = settings_UI.get_node("highscore")
	highscore_txt.text = "HIGH SCORE = " + str(highscore)


func _on_closeButton_pressed():
	settings_UI.hide()
	is_settings_open = false
	get_tree().paused = false
