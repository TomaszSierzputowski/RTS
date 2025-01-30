extends CharacterBody2D

@export var selected: bool = false
@onready var highlight = $highlight
@onready var main_base_red = $main_base_red
@onready var main_base_blue = $main_base_blue
@onready var building_type
@onready var building_type_outline
var max_health: int = 100
@export var health: int = max_health
@export var player_color: bool = false
@onready var building_id: int
var current_position : Vector2
var new_position : Vector2


func init_base(_id: int, _color: bool, _position: Vector2) -> void:
	building_id = _id
	player_color = _color
	position = _position
	if player_color == false:
		building_type = $main_base_red
		building_type_outline = $red_outline
		print("Red main base with id: ", building_id, " added")
	else:
		building_type = $main_base_blue
		building_type_outline = $blue_outline
		print("Blue main base with id: ", building_id, " added")
	building_type.visible = true
	building_type_outline.visible = true


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
	health += value
	if(health > 0):
		print("health is ", health)
	else:
		print("you are dead hehehe")
	var alpha = health / float(max_health)
	building_type.self_modulate.a = clamp(alpha, 0.0, 1.0)

	
func get_current_position() -> Vector2:
	return global_position
