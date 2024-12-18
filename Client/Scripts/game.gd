extends Node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called when an input event is detected
func _input(event: InputEvent) -> void:
	pass

func _ready():
	#$ChildNode.connect("was_selected", _on_select_unit())
	pass

func _on_select_unit():
	print("Unit was selected!")
