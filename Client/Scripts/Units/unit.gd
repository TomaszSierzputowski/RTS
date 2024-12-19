extends CharacterBody2D

@export var selected: bool = false
@onready var highlight = $highlight
@onready var unit_1_red = $unit_1_red
@onready var unit_1_blue = $unit_1_blue
@onready var unit_type
@export var hp: int
var max_hp: int = 100
@export var unit_color: bool = false

signal was_selected
signal was_deselected

func _ready() -> void:
	if unit_color == false:
		unit_type = $unit_1_red
	else:
		unit_type = $unit_1_blue
	unit_type.visible = true

 
func _process(delta: float) -> void:
	highlight.visible = selected
	var alpha = hp / float(max_hp)
	unit_type.self_modulate.a = clamp(alpha, 0.0, 1.0)

	
	
func set_selected(value: bool) -> void:
	if selected != value:
		selected = value
		highlight.visible = value
		if selected:
			emit_signal("was_selected", self)
		else:
			emit_signal("was_deselected", self)
		
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and selected == false:
			set_selected(true)
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and selected == true:
			set_selected(false)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			hp -= 5
