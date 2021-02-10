extends Node

onready var view_width = get_viewport().get_visible_rect().size.x
onready var view_height = get_viewport().get_visible_rect().size.y
onready var bricksContainer = get_node("/root/Game/Bricks_Container")

var total_active_bricks
var bricks_data


func _ready():
	print("Bricks_Manager: _ready")
	load_bricks_data()


func init_level(level_bricks):
	total_active_bricks = 0
	release_all_bricks()
	create_bricks(level_bricks)


func load_bricks_data():
	var path = "res://Extra/Bricks_Data.json"
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
	bricks_data = result_json.result
	print(bricks_data)


func create_bricks(level_bricks):
	var brick_scenes = {}
	var column_spacing = 5
	var row_spacing = 5
	var row_initial_spacing = 30
	var bricks = []
	for row in level_bricks.size():
		bricks.append([])
		var total_bricks_in_row = level_bricks[row].size()
		bricks[row].resize(total_bricks_in_row)
		for column in total_bricks_in_row:
			var brick_type = level_bricks[row][column]
			var brick_instance
			var brick_scn
			
			if bricks_data.empty_brick_type == brick_type:
				continue
			
			var brick_data = bricks_data.bricks_type_map[str(brick_type)]
			if brick_scenes.has(str(brick_type)):
				brick_scn = brick_scenes[str(brick_type)]
				brick_instance = brick_scn.instance()
			elif bricks_data.bricks_type_map.has(str(brick_type)):
				brick_scenes[str(brick_type)] = load("res://Scenes/Bricks/" + str(brick_data.name) + ".tscn")
				brick_instance = brick_scenes[str(brick_type)].instance()
			else:
				printerr("Brick type in level data doesnt exist! brick_type = " + str(brick_type))
				
			if brick_instance:
				brick_instance.name = str(brick_type) + "_" + str(brick_data.hits_to_destroy) + "|"
				var brick_half_size = brick_instance.get_node("CollisionShape2D").shape.get_extents()
				bricksContainer.add_child(brick_instance, true)
				bricks[row][column] = brick_instance
				brick_instance.position.x = column * (column_spacing + (brick_half_size.x * 2)) + brick_half_size.x
				brick_instance.position.x += (view_width - (total_bricks_in_row * ( column_spacing + (brick_half_size.x * 2))) + column_spacing) / 2
				brick_instance.position.y = row_initial_spacing + row * (row_spacing + (brick_half_size.y * 2)) + brick_half_size.y
				total_active_bricks += 1


func release_all_bricks():
	for brick in bricksContainer.get_children():
		brick.queue_free()


func get_brick_name_data(brick_instance):
	var brick_type
	var hits_to_destroy
	var brick_name = brick_instance.name
	var brick_type_sperator_index = brick_name.find("_")
	var brick_hits_sperator_index = brick_name.find("|")
	if brick_type_sperator_index == -1:
		printerr("Brick name does not include '_' char")
	elif brick_hits_sperator_index == -1:
		printerr("Brick name does not include '|' char")
		
	brick_type = brick_name.substr(0, brick_type_sperator_index)
	var length = brick_hits_sperator_index - brick_type_sperator_index - 1
	hits_to_destroy = brick_name.substr(brick_type_sperator_index + 1, length)
	return [brick_type, hits_to_destroy]


func on_ball_hit_brick(hit_id):
	var brick_instance = instance_from_id(hit_id) 
	var brick_name_data = get_brick_name_data(brick_instance)
	var brick_data = bricks_data.bricks_type_map[str(brick_name_data[0])]
	SignalsManager.emit_signal("update_user_add_score", brick_data.score)
	var hits_to_destroy = int(brick_name_data[1])
	hits_to_destroy -= 1
	if hits_to_destroy == 0:
		brick_instance.queue_free()
		total_active_bricks -= 1
		print("total_active_bricks = " + str(total_active_bricks))
		if total_active_bricks <= 0:
			SignalsManager.emit_signal("level_completed")
	else:
		set_brick_hit(brick_instance, hits_to_destroy)
		#TODO: set animation state of the brick.


func set_brick_hit(brick_instance, new_val):
	var brick_name = brick_instance.name
	var brick_type_sperator_index = brick_name.find("_")
	var brick_hits_sperator_index = brick_name.find("|")
	var brick_new_name = brick_name.substr(0, brick_type_sperator_index + 1) + str(new_val) + brick_name.substr(brick_hits_sperator_index)
	brick_instance.name = brick_new_name
	add_brick_hit_lines(brick_instance)


# Create 'shattered' lines on the hit brick. (in the future will replace this shattered animation)
func add_brick_hit_lines(brick_instance):
	var line2D = brick_instance.get_node("Line2D")
	line2D.set_default_color(Color(0,0,0))
	line2D.set_width(1.1)
	
	var brick_half_size = brick_instance.get_node("CollisionShape2D").shape.get_extents()
	randomize()
	var previous_point_side = 0
	for i in 12:
		var randX = rand_range(-brick_half_size.x, brick_half_size.x)
		var randY = rand_range(-brick_half_size.y, brick_half_size.y)
		var rand_side = randi()%4 + 1
		# make sure every line goes from a side to another and on the same side.
		while previous_point_side == rand_side:
			rand_side = randi()%4 + 1
		previous_point_side = rand_side
		if rand_side == 1:
			line2D.add_point(Vector2(randX, -brick_half_size.y))
		if rand_side == 2:
			line2D.add_point(Vector2(randX, brick_half_size.y))
		if rand_side == 3:
			line2D.add_point(Vector2(brick_half_size.x, randY))
		if rand_side == 4:
			line2D.add_point(Vector2(-brick_half_size.x, randY))
