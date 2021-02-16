extends Node

onready var HUD = get_node("/root/Game/HUD")

const max_total_lives = 3

var score_count
var lives_count
var cached_user_data

func _ready():
	SignalsManager.connect("update_user_set_score", self, "set_score")
	SignalsManager.connect("update_user_add_score", self, "add_score")
	SignalsManager.connect("user_power_up_collected", self, "on_powerup_collected")
	load_user_data()

func init():
	score_count = 0
	lives_count = max_total_lives
	HUD.update_ui(score_count, lives_count)


func set_score(new_score):
	score_count = new_score
	HUD.update_ui(score_count, lives_count)


func add_score(add_score):
	score_count += add_score
	HUD.update_ui(score_count, lives_count)


func increase_life(amount = 1):
	if lives_count == max_total_lives:
		return
	else:
		lives_count += amount
		lives_count = clamp(lives_count, 0, max_total_lives)
		HUD.update_ui(score_count, lives_count)


func decrease_life(amount = 1):
	var is_game_over = false
	
	if lives_count > 0:
		lives_count -= amount
		HUD.update_ui(score_count, lives_count)
		if lives_count == 0:
			SignalsManager.emit_signal("game_over")
			is_game_over = true
	
	return is_game_over


func on_powerup_collected(powerup_id, powerup_data):
	print("User: on_powerup_collected")
	print(powerup_data)
	print(powerup_id)
	
	match powerup_id:
		"extra_life":
			increase_life(powerup_data.amount)


func load_user_data():
	print("load_user_data")
	var path = "res://Extra/User_Data.json"
	var file = File.new()
	file.open(path, file.READ)
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error != OK:
		printerr("[load_json_file] Error loading JSON file '" + str(path) + "'.")
		printerr("\tError: ", result_json.error)
		printerr("\tError Line: ", result_json.error_line)
		printerr("\tError String: ", result_json.error_string)
		return null
	cached_user_data = result_json.result
	print(cached_user_data)
	file.close()


func save_highscore():
	var path = "res://Extra/User_Data.json"
	var file = File.new()
	file.open(path, file.WRITE)
	var data = {}
	data["highscore"] = score_count
	file.store_string(JSON.print(data, "  ", true))
	cached_user_data.highscore = score_count
	file.close()


func get_highscore():
	return cached_user_data.highscore


func on_game_over():
	if cached_user_data and cached_user_data.highscore and cached_user_data.highscore > score_count:
		return
	save_highscore()
