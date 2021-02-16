extends Area2D

signal killed(this)

onready var view_height = get_viewport().get_visible_rect().size.y
onready var bullet_radius = get_node("CollisionShape2D").shape.radius
 
export var speed = 400

# used by the Paddle_Powerups_Handler to control when to enable this bullet after the pool gave it life.
var is_active setget set_active, get_active

# used by the pool to manage dead/alive objects.
var dead setget set_dead, get_dead

func _ready():
	is_active = false
	dead = true

func _physics_process(delta):
	if is_active and not dead:
		global_position += Vector2.UP * speed * delta
	
			# Ceiling.
		if global_position.y < bullet_radius:
			kill()


func set_active(val):
	is_active = val


func get_active():
	return 


func set_dead(val):
	dead = val


func get_dead():
	return dead


func _on_Bullet_area_entered(area):
	if not is_active:
		return
	
	if area.is_in_group("Brick"):
		SignalsManager.emit_signal("player_hit_brick", area.get_instance_id())
		kill()


func kill():
	is_active = false
	dead = true
	emit_signal("killed", self)
