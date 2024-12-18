extends CharacterBody2D

@export var selected: bool = false
@onready var box = $box
@onready var unit_1_red = $unit_1_red
@onready var unit_1_blue = $unit_1_blue
@onready var unit_2_red = $unit_2_red
@onready var unit_2_blue = $unit_2_blue

var visible_array = [true, false, false, false]

signal was_selected
signal was_deselected

func _ready() -> void:
	pass

 
func _process(delta: float) -> void:
	box.visible = selected
	
func set_selected(value: bool) -> void:
	if selected != value:
		selected = value
		box.visible = value
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
