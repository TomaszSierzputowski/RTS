extends CharacterBody2D

@export var selected: bool = false
@onready var highlight = $highlight
@onready var building_2_red = $building_2_red
@onready var building_2_blue = $building_2_blue
@onready var building_type
@onready var building_type_outline
@onready var unit_type
var max_health: int = 100
@export var health: int = max_health
@export var player_color: bool = false
@onready var building_id: int
var current_position : Vector2
var new_position : Vector2


func init_building(_id: int, _color: bool, _position: Vector2, _unit_type: int) -> void:
	building_id = _id
	player_color = _color
	position = _position
	unit_type = _unit_type
	if unit_type == 1:
		$unit_1_shape.visible = true
	elif unit_type == 2:
		$unit_2_shape.visible = true
	elif unit_type == 3:
		$unit_3_shape.visible = true
	elif unit_type == 4:
		$unit_4_shape.visible = true
	if player_color == false:
		building_type = $building_2_red
		building_type_outline = $red_outline
		print("Red main base with id: ", building_id, " added")
	else:
		building_type = $building_2_blue
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
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and selected == false:
			#set_selected(true)
			pass
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and selected == true:
			#new_position = event.global_position
			#change_position(current_position, new_position)
			#set_selected(false)
			pass
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			change_health(-5)
			#new_position = Vector2(position.x - 5, position.y - 5)
			#change_position(current_position, new_position)
			#health -= 5
			
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
