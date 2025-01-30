extends CharacterBody2D

@export var selected: bool = false
@onready var highlight = $highlight
@onready var unit_2_red = $unit_2_red
@onready var unit_2_blue = $unit_2_blue
@onready var unit_type
@onready var unit_type_outline
var max_health: int = 100
@export var health: int = max_health
@export var player_color: bool = false
@onready var unit_id: int
var current_position : Vector2
var new_position : Vector2


func init_unit(_id: int, _color: bool, _position: Vector2) -> void:
	unit_id = _id
	player_color = _color
	position = _position
	if player_color == false:
		unit_type = $unit_2_red
		unit_type_outline = $red_outline
		print("Red unit of type 2 with id: ", unit_id, " added")
	else:
		unit_type = $unit_2_blue
		unit_type_outline = $blue_outline
		print("Blue unit of type 2 with id: ", unit_id, " added")
	unit_type.visible = true
	unit_type_outline.visible = true


func _ready() -> void:
	pass

 
func _process(delta: float) -> void:
	highlight.visible = selected
	current_position = global_position

	
func set_selected(value: bool) -> void:
	if selected != value:
		selected = value
		highlight.visible = value
			
			
func change_health(value: float) -> void:
	health = value
	if(health > 0):
		print("health is ", health)
	else:
		print("you are dead hehehe")
	var alpha = health / float(max_health)
	unit_type.self_modulate.a = clamp(alpha, 0.0, 1.0)
	
	
func change_position(current_position: Vector2, new_position: Vector2) -> void:
	var delta_x = new_position.x - current_position.x
	var delta_y = new_position.y - current_position.y
	var rotate_amount = atan2(delta_y, delta_x)

	position = new_position
	rotation = rotate_amount
	
	
func get_current_position() -> Vector2:
	return global_position
