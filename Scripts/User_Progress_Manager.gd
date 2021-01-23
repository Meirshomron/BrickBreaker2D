extends Node

onready var HUD = get_node("/root/Game/HUD")

var score
var score_txt


func _ready():
	score = 0
	SignalsManager.connect("update_user_set_score", self, "set_score")
	SignalsManager.connect("update_user_add_score", self, "add_score")

func init():
	score_txt = HUD.get_node("Score")
	update_ui()


func set_score(new_score):
	score = new_score
	update_ui()


func add_score(add_score):
	score += add_score
	update_ui()


func update_ui():
	#TODO: set ui score
	score_txt.text = "SCORE: " + str(score)
