extends Node2D



func _on_StartButton_button_up():
	SignalsManager.emit_signal("start_level")
	hide()
