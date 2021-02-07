extends Node2D

onready var pauseBtn = $pauseButton
onready var resumeBtn = $resumeButton

var is_paused
var orig_scale
var pressed_scale

func _ready():
	is_paused = true
	orig_scale = Vector2(.3, .3)
	pressed_scale = Vector2(.25, .25)


func _on_resumeButton_button_up():
	get_tree().paused = false
	resumeBtn.set_visible(false)
	pauseBtn.set_visible(true)
	pauseBtn.set_scale(orig_scale)


func _on_pauseButton_button_up():
	print("up")
	get_tree().paused = true
	pauseBtn.set_visible(false)
	resumeBtn.set_visible(true)
	resumeBtn.set_scale(orig_scale)


func _on_pauseButton_button_down():
	print("down")
	pauseBtn.set_scale(pressed_scale)


func _on_resumeButton_button_down():
	resumeBtn.set_scale(pressed_scale)



