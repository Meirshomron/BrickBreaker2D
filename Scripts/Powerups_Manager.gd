extends Node

onready var view_height = get_viewport().get_visible_rect().size.y
onready var powerupsContainer = get_node("/root/Game/Powerups_Container")

var powerups_data
var current_level_powerups_data
var current_active_powerups
var falling_speed


func _ready():
	print("Powerups_Manager: _ready")
	load_powerups_data()
	falling_speed = 150
	current_active_powerups = []
	SignalsManager.connect("power_up_collected", self, "on_powerup_collected")
	randomize()


func load_powerups_data():
	var path = "res://Extra/Powerups_Data.json"
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
	powerups_data = result_json.result
	print(powerups_data)


func _physics_process(delta):
	for powerup in current_active_powerups:
		powerup.position.y += delta * falling_speed
		# Remove if out of screan bounds.
		if powerup.position.y > view_height:
			current_active_powerups.erase(powerup)
			powerup.queue_free()


func init_level(level_powerups):
	current_level_powerups_data = level_powerups
	release_all_powerups()


func on_ball_hit_brick(hit_id):
#	print("Powerups_Manager: _on_ball_hit_brick")
	var powerup_id = calculate_powerup()
	if powerup_id:
		print("powerup_id = " + str(powerup_id))
		var brick_instance = instance_from_id(hit_id) 
		var powerup_scene = load("res://Scenes/Powerups/" + powerup_id + ".tscn")
		var powerup_instance = powerup_scene.instance()
		powerup_instance.name = str(powerup_id) + "|"
		powerupsContainer.add_child(powerup_instance, true)
		powerup_instance.position = brick_instance.position
		powerup_instance.get_node("AnimationPlayer").play(powerup_id)
		current_active_powerups.push_front(powerup_instance)


func calculate_powerup():
#	print("calculate_powerup")

	var rand = rand_range(0, 1)
	if rand < current_level_powerups_data.powerups_probabilities:
		rand = rand_range(0, 1)
		var sum_probabilities = 0
		var prev_sum_probabilities
		for powerup_id in current_level_powerups_data.probabilities:
			prev_sum_probabilities = sum_probabilities
			sum_probabilities += current_level_powerups_data.probabilities[powerup_id]
			if rand < sum_probabilities && rand > prev_sum_probabilities:
				return powerup_id
	return null


func on_powerup_collected(instance_id):
	print("Powerups_Manager: on_powerup_collected")
	var powerup_instance = instance_from_id(instance_id) 
	current_active_powerups.erase(powerup_instance)
	powerup_instance.queue_free()
	
	# emit signal for the right handle of executing the powerup power ball_controller/paddle..etc.
	var collected_powerup_name = powerup_instance.name
	var powerup_type_sperator_index = collected_powerup_name.find("|")
	var collected_powerup_id = collected_powerup_name.substr(0, powerup_type_sperator_index)
	var collected_powerup_data = powerups_data.powerups_type_map[collected_powerup_id]
	print("emit " +  collected_powerup_data.handler + "_power_up_collected")
	SignalsManager.emit_signal(collected_powerup_data.handler + "_power_up_collected", collected_powerup_id, collected_powerup_data)
	SignalsManager.emit_signal("update_user_add_score", collected_powerup_data.score)

func release_all_powerups():
	current_active_powerups = []
	for powerup in powerupsContainer.get_children():
		powerup.queue_free()
