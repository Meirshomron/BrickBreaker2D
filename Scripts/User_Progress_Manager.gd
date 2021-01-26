extends Node

onready var HUD = get_node("/root/Game/HUD")

const max_total_lives = 3

var score_count
var score_txt
var lives_count
var lives_parent

func _ready():
	SignalsManager.connect("update_user_set_score", self, "set_score")
	SignalsManager.connect("update_user_add_score", self, "add_score")
	SignalsManager.connect("increase_user_life", self, "increase_life")
	SignalsManager.connect("decrease_user_life", self, "decrease_life")

func init():
	score_txt = HUD.get_node("Score")
	lives_parent = HUD.get_node("Lives")
	score_count = 0
	lives_count = max_total_lives
	update_ui()


func set_score(new_score):
	score_count = new_score
	update_ui()


func add_score(add_score):
	score_count += add_score
	update_ui()


func increase_life():
	if lives_count == max_total_lives:
		return
	else:
		lives_count += 1
		update_ui()


func decrease_life():
	if lives_count == 0:
		return
	else:
		lives_count -= 1
		update_ui()
		if lives_count == 0:
			SignalsManager.emit_signal("game_over")


func update_ui():
	#TODO: set ui score
	score_txt.text = "SCORE: " + str(score_count)
	for i in range(1, 4):
		var live_img = lives_parent.get_node("Life_" + str(i))
		if i <= lives_count:
			live_img.set_visible(true)
		else:
			live_img.set_visible(false)
			
