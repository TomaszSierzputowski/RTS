extends TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Input.is_action_just_pressed and event.is_pressed():
		if Input.is_action_just_pressed:
			print(get_global_mouse_position())
			get_tile_id(get_global_mouse_position())

func get_tile_id(coordinates: Vector2) -> int:
	var tile_position = local_to_map(coordinates)
	var cell_id = get_cell_source_id(tile_position)
	print(cell_id)
	return cell_id

func get_position_on_map(coordinates: Vector2) -> Vector2:
	return map_to_local(coordinates)
