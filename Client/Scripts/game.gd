extends Node

var resource_amount : int
var unit_1 = preload("res://Client/Scenes/Units/unit_1.tscn")
var unit_2 = preload("res://Client/Scenes/Units/unit_2.tscn")
var main_base = preload("res://Client/Scenes/Buildings/main_base.tscn")
var building_1 = preload("res://Client/Scenes/Buildings/building_1.tscn")
var id_num = 0
var unit_1_price = 10
var unit_2_price = 10
var main_base_price = 20
var building_1_price = 10
var base_exists : bool = false
var button_pressed : bool = false
var player_color: bool

var red_units = []
var blue_units = []
var red_buildings = []
var blue_buildings = []

@onready var stats_amount_label = $CanvasLayer/menuPanel/menuVBoxContainer/statsBodyLabel
@onready var unit_1_button = $CanvasLayer/menuPanel/menuVBoxContainer/unit1button
@onready var unit_2_button = $CanvasLayer/menuPanel/menuVBoxContainer/unit2button
@onready var main_base_button = $CanvasLayer/menuPanel/menuVBoxContainer/mainBaseButton
@onready var building_button = $CanvasLayer/menuPanel/menuVBoxContainer/buildingButton

@onready var server = get_node("/root/Server")
@onready var selection_box = $SelectionBox

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if base_exists == false:
		unit_1_button.disabled = true
		unit_2_button.disabled = true
		main_base_button.disabled = false
		building_button.disabled = true
	else:
		unit_1_button.disabled = false
		unit_2_button.disabled = false
		main_base_button.disabled = true
		building_button.disabled = false
		
	# obsługa sygnału zmieniającego ilość surowca
	# obsługa sygnału zmieniającego położenie jednostek
	stats_amount_label.text = str(resource_amount)
	


# Called when an input event is detected
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and $unit_2.selected == true:
			var new_position : Vector2
			new_position = $Map.get_global_mouse_position()
			var current_position = $unit_2.get_current_position()
			$unit_2.change_position(current_position, new_position)
			$unit_2.set_selected(false)
		elif button_pressed == false and unit_1_button.disabled == false and unit_1_button.button_pressed:
			button_pressed = true
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if get_resource_amount() >= unit_1_price:
					var coords = $Map.get_global_mouse_position()
					add_unit1(coords, id_num, player_color)
				else:
					print("you do not have enough resource")
			button_pressed = false
		elif button_pressed == false and unit_2_button.disabled == false and unit_2_button.button_pressed:
			button_pressed = true
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if get_resource_amount() >= unit_2_price:
					var coords = $Map.get_global_mouse_position()
					add_unit2(coords, id_num, player_color)
				else:
					print("you do not have enough resource")
			button_pressed = false
		elif button_pressed == false and main_base_button.disabled == false and main_base_button.button_pressed and base_exists == false:
			button_pressed = true
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if get_resource_amount() >= main_base_price:
					var coords = $Map.get_global_mouse_position()
					add_main_base(coords, player_color)
					base_exists = true
				else:
					print("you do not have enough resource")
			button_pressed = false
		elif button_pressed == false and building_button.disabled == false and building_button.button_pressed:
			button_pressed = true
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if get_resource_amount() >= building_1_price:
					var coords = $Map.get_global_mouse_position()
					add_building_1(coords, id_num, player_color)
				else:
					print("you do not have enough resource")
			button_pressed = false
			
		

func _ready():
	# czekaj na sygnał z serwera mówiący ile wstepnie jest dostępne surowca
	# do usunięcia potem to dokładne nadpisanie
	resource_amount = 200
	# pobierz z servera kolor gracza
	player_color = false
	pass
	
func get_resource_amount() -> int:
	return resource_amount
	
func add_unit1(position: Vector2, id: int, color: bool) -> void:
	var new_unit = unit_1.instantiate()
	new_unit.position = position
	new_unit.init_unit(id, color, position)
	add_child(new_unit)
	# zamiast zmniejszania ilosci surowca powinno byc wysłanie sygnału do serwera zeby zmniejszyc
	resource_amount -= unit_1_price
	print("added unit succesfully")
	id_num += 1
	
	if color == false:
		red_units.append({
			"id": id,
			"type": 1,
			"position": position,
			"instance": new_unit
		})
		print("saved to array")
	else:
		blue_units.append({
			"id": id,
			"type": 1,
			"position": position,
			"instance": new_unit
		})
		print("saved to array")
	
func add_unit2(position: Vector2, id: int, color: bool) -> void:
	var new_unit = unit_2.instantiate()
	new_unit.position = position
	new_unit.init_unit(id, color, position)
	add_child(new_unit)
	# zamiast zmniejszania ilosci surowca powinno byc wysłanie sygnału do serwera zeby zmniejszyc
	resource_amount -= unit_2_price
	print("added unit succesfully")
	id_num += 1
	
	if color == false:
		red_units.append({
			"id": id,
			"type": 2,
			"position": position,
			"instance": new_unit
		})
		print("saved to array")
	else:
		blue_units.append({
			"id": id,
			"type": 2,
			"position": position,
			"instance": new_unit
		})
		print("saved to array")
		
func add_main_base(position: Vector2, color: bool) -> void:
	var new_building = main_base.instantiate()
	new_building.position = position
	new_building.init_base(0, color, position)
	add_child(new_building)
	# zamiast zmniejszania ilosci surowca powinno byc wysłanie sygnału do serwera zeby zmniejszyc
	resource_amount -= main_base_price
	print("added unit succesfully")
	id_num += 1
	
	if color == false:
		red_buildings.append({
			"id": 0,
			"type": 0,
			"position": position,
			"instance": new_building
		})
		print("saved to array")
	else:
		blue_buildings.append({
			"id": 0,
			"type": 0,
			"position": position,
			"instance": new_building
		})
		print("saved to array")
	
func add_building_1(position: Vector2, id: int, color: bool) -> void:
	var new_building = building_1.instantiate()
	new_building.position = position
	new_building.init_building(id, color, position)
	add_child(new_building)
	# zamiast zmniejszania ilosci surowca powinno byc wysłanie sygnału do serwera zeby zmniejszyc
	resource_amount -= building_1_price
	print("added unit succesfully")
	id_num += 1
	
	if color == false:
		red_buildings.append({
			"id": id,
			"type": 1,
			"position": position,
			"instance": new_building
		})
		print("saved to array")
	else:
		blue_buildings.append({
			"id": id,
			"type": 1,
			"position": position,
			"instance": new_building
		})
		print("saved to array")
	
func get_last_id():
	return id_num
	
func get_unit_by_id(unit_id: int, color: bool):
	if color == false:
		for unit in red_units:
			if unit["id"] == unit_id:
				return unit
		#return null
	else:
		for unit in blue_units:
			if unit["id"] == unit_id:
				return unit
		#return null

func move_unit(unit_id: int, new_position: Vector2, color: bool):
	var unit_data = get_unit_by_id(unit_id, color)
	if unit_data != null:
		var current_position = unit_data["position"]
		unit_data["instance"].change_position(current_position, new_position)
		unit_data["position"] = new_position
		print("unit ", unit_id, " of color ", color, " changed position")
		
	
