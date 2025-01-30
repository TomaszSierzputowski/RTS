extends Node2D

var resource_amount : int
var unit_1 = preload("res://Client/Scenes/Units/unit_1.tscn")
var unit_2 = preload("res://Client/Scenes/Units/unit_2.tscn")
var unit_3 = preload("res://Client/Scenes/Units/unit_3.tscn")
var unit_4 = preload("res://Client/Scenes/Units/unit_4.tscn")
var main_base = preload("res://Client/Scenes/Buildings/main_base.tscn")
var building_1 = preload("res://Client/Scenes/Buildings/building_1.tscn")
var building_2 = preload("res://Client/Scenes/Buildings/building_2.tscn")

var id_num = 0
var unit_1_price = 10
var unit_2_price = 30
var unit_3_price = 15
var unit_4_price = 30
var main_base_price = 0
var building_2_1_price = 50
var building_2_2_price = 600
var building_2_3_price = 100
var building_2_4_price = 100
var base_exists : bool = false
var unit_1_base_exists : bool = false
var unit_2_base_exists : bool = false
var unit_3_base_exists : bool = false
var unit_4_base_exists : bool = false
var button_pressed : bool = false
var player_color: bool
var offset: int

var red_table = []
var blue_table = []

@onready var stats_amount_label = $CanvasLayer/menuPanel/menuVBoxContainer/statsBodyLabel
@onready var unit_1_button = $CanvasLayer/menuPanel/menuVBoxContainer/unit1button
@onready var unit_2_button = $CanvasLayer/menuPanel/menuVBoxContainer/unit2button
@onready var unit_3_button = $CanvasLayer/menuPanel/menuVBoxContainer/unit3button
@onready var unit_4_button = $CanvasLayer/menuPanel/menuVBoxContainer/unit4button
@onready var main_base_button = $CanvasLayer/menuPanel/menuVBoxContainer/mainBaseButton
@onready var unit_1_building_button = $CanvasLayer/menuPanel/menuVBoxContainer/unit1buildingButton
@onready var unit_2_building_button = $CanvasLayer/menuPanel/menuVBoxContainer/unit2buildingButton
@onready var unit_3_building_button = $CanvasLayer/menuPanel/menuVBoxContainer/unit3buildingButton
@onready var unit_4_building_button = $CanvasLayer/menuPanel/menuVBoxContainer/unit4buildingButton
@onready var menu_panel = $CanvasLayer/menuPanel
@onready var selection_layer = $selectionLayer
@onready var tree = get_tree()

var dragging = false
var selected = []
var drag_start = Vector2.ZERO
var select_rect = RectangleShape2D.new()
var selected_ids = []
var target = Vector2()
var selected_and_target = []

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if selected.size() == 0:
					dragging = true
					drag_start = $Map.get_global_mouse_position()
				else:
					deselect_all()
			elif dragging:
				dragging = false
				var drag_end = $Map.get_global_mouse_position()
				select_units_in_area(drag_start, drag_end)


func select_units_in_area(start: Vector2, end: Vector2) -> void:
	select_rect.extents = abs(end - start) / 2
	var rect_center = (start + end) / 2

	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = select_rect
	query.collision_mask = 2
	query.transform = Transform2D(0, rect_center)

	selected = space.intersect_shape(query)
	
	for item in selected:
		item.collider.set_selected(true)
		
	for selection in selected:
		var unit = selection.collider
		var selected_id = get_id_from_instance(unit)
		if selected_id != -1:
			selected_ids.append(selected_id)

	#print("Selected ids: ", selected_ids)


func deselect_all() -> void:
	for item in selected:
		item.collider.set_selected(false)
	selected.clear()
	selected_ids.clear()


func _process(delta: float) -> void:
	display_buttons()
		
	stats_amount_label.text = str(resource_amount)
	var window_size = DisplayServer.window_get_size()
	offset = window_size.x - menu_panel.custom_minimum_size.x
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if button_pressed == false and unit_1_button.disabled == false and unit_1_button.button_pressed:
			check_and_add_unit_1_on_pressed(event)
		elif button_pressed == false and unit_2_button.disabled == false and unit_2_button.button_pressed:
			check_and_add_unit_2_on_pressed(event)
		elif button_pressed == false and unit_3_button.disabled == false and unit_3_button.button_pressed:
			check_and_add_unit_3_on_pressed(event)
		elif button_pressed == false and unit_4_button.disabled == false and unit_4_button.button_pressed:
			check_and_add_unit_4_on_pressed(event)
		elif button_pressed == false and main_base_button.disabled == false and main_base_button.button_pressed and base_exists == false:
			check_and_add_main_base_on_pressed(event)
		elif button_pressed == false and unit_1_building_button.disabled == false and unit_1_building_button.button_pressed:
			check_and_add_building_2_on_pressed(event, 1)
		elif button_pressed == false and unit_2_building_button.disabled == false and unit_2_building_button.button_pressed:
			check_and_add_building_2_on_pressed(event, 2)
		elif button_pressed == false and unit_3_building_button.disabled == false and unit_3_building_button.button_pressed:
			check_and_add_building_2_on_pressed(event, 3)
		elif button_pressed == false and unit_4_building_button.disabled == false and unit_4_building_button.button_pressed:
			check_and_add_building_2_on_pressed(event, 4)
		elif event.button_index == MOUSE_BUTTON_RIGHT and selected_ids != []:
			target = $Map.get_global_mouse_position()
			#print(target)
			#selected_and_target = selected_ids
			#selected_and_target.append(target)
			# tu pewnie cos trzeba wkleic i pewnie zmienic tę tablicę, tomek to zadanie dla ciebie
			Client.move(selected_ids, target)
			deselect_all()
			target = Vector2()
		

func _ready():
	resource_amount = 200
	player_color = true
	red_table.resize(256)
	blue_table.resize(256)
	Client.summon_build.connect(summon_build)
	Client.set_resources.connect(set_resource_amount)
	Client.change_position.connect(change_position)
	Client.change_health.connect(change_hp)
	Client.die_destroy.connect(die_destroy)

func set_resource_amount(val : int) -> void:
	resource_amount = val


func get_resource_amount() -> int:
	return resource_amount


func summon_build(player : int, id : int, type : Utils.EntityType, position : Vector2, health : int) -> void:
	if player == 0 and blue_table[id] != null:
		return
	if player == 1 and red_table[id] != null:
		return
	match type:
		Utils.EntityType.MAIN_BASE:
			add_main_base(position, player == 0)
		Utils.EntityType.MINE_YES:
			add_building_2(position, id, player == 0, 1)
		Utils.EntityType.TRIANGLE_YES:
			add_building_2(position, id, player == 0, 3)
		Utils.EntityType.SQUARE_YES:
			add_building_2(position, id, player == 0, 4)
		Utils.EntityType.PENTAGON_YES:
			add_building_2(position, id, player == 0, 2)
		Utils.EntityType.WORKER:
			add_unit1(position, id, player == 0)
		Utils.EntityType.PENTAGON:
			add_unit2(position, id, player == 0)
		Utils.EntityType.TRIANGLE:
			add_unit3(position, id, player == 0)
		Utils.EntityType.SQUARE:
			add_unit4(position, id, player == 0)


func add_unit1(position: Vector2, id: int, color: bool) -> void:
	var new_unit = unit_1.instantiate()
	new_unit.position = position
	new_unit.init_unit(id, color, position)
	add_child(new_unit)
	resource_amount -= unit_1_price
	#print("added unit succesfully")
	id_num += 1
	
	if color == false:
		red_table[id] = {
			"type": 1,
			"position": position,
			"instance": new_unit
		}
		#print("saved to array")
	else:
		blue_table[id] = {
			"type": 1,
			"position": position,
			"instance": new_unit
		}
		#print("saved to array")
	
	
func add_unit2(position: Vector2, id: int, color: bool) -> void:
	var new_unit = unit_2.instantiate()
	new_unit.position = position
	new_unit.init_unit(id, color, position)
	add_child(new_unit)
	resource_amount -= unit_2_price
	#print("added unit succesfully")
	id_num += 1
	
	if color == false:
		red_table[id] = {
			"type": 2,
			"position": position,
			"instance": new_unit
		}
		#print("saved to array")
	else:
		blue_table[id] = {
			"type": 2,
			"position": position,
			"instance": new_unit
		}
		#print("saved to array")
		
		
func add_unit3(position: Vector2, id: int, color: bool) -> void:
	var new_unit = unit_3.instantiate()
	new_unit.position = position
	new_unit.init_unit(id, color, position)
	add_child(new_unit)
	resource_amount -= unit_3_price
	#print("added unit succesfully")
	id_num += 1
	
	if color == false:
		red_table[id] = {
			"type": 3,
			"position": position,
			"instance": new_unit
		}
		#print("saved to array")
	else:
		blue_table[id] = {
			"type": 3,
			"position": position,
			"instance": new_unit
		}
		#print("saved to array")
		
		
func add_unit4(position: Vector2, id: int, color: bool) -> void:
	var new_unit = unit_4.instantiate()
	new_unit.position = position
	new_unit.init_unit(id, color, position)
	add_child(new_unit)
	resource_amount -= unit_4_price
	#print("added unit succesfully")
	id_num += 1
	
	if color == false:
		red_table[id] = {
			"type": 4,
			"position": position,
			"instance": new_unit
		}
		#print("saved to array")
	else:
		blue_table[id] = {
			"type": 4,
			"position": position,
			"instance": new_unit
		}
		#print("saved to array")

func add_main_base(position: Vector2, color: bool) -> void:
	var new_building = main_base.instantiate()
	new_building.position = position
	new_building.init_base(0, color, position)
	add_child(new_building)
	resource_amount -= main_base_price
	#print("added unit succesfully")
	id_num += 1
	
	if color == false:
		red_table[0] = {
			"type": 0,
			"position": position,
			"instance": new_building
		}
		#print("saved to array")
	else:
		blue_table[0] = {
			"type": 0,
			"position": position,
			"instance": new_building
		}
		#print("saved to array")
	
		
func add_building_2(position: Vector2, id: int, color: bool, unit_type: int) -> void:
	var new_building = building_2.instantiate()
	new_building.position = position
	new_building.init_building(id, color, position, unit_type)
	add_child(new_building)
	#print("added building succesfully")
	id_num += 1
	
	if color == false:
		red_table[id] = {
		"type": 2,
		"position": position,
		"instance": new_building
	}
		#print("saved to array")
	else:
		blue_table[id] = {
			"type": 2,
			"position": position,
			"instance": new_building
		}
		#print("saved to array")
	
	
func get_last_id():
	return id_num
	
	
func get_by_id(id: int, color: bool):
	if id <= 255 or id >= 0:
		if color == false:
			return red_table[id]
		else:
			return blue_table[id]
	else:
		return -1
	
		
func get_id_from_instance(instance: CharacterBody2D) -> int:
	for id in range(256):
		if blue_table[id] != null and blue_table[id].instance == instance:
			return id
	return -1
	

func die_destroy(player : int, id : int) -> void:
	if (id == 0):
		if (player == 1):
			print("You have won")
		else:
			print("You have lost")
		tree.change_scene_to_file("res://Client/Scenes/welcome_menu.tscn")
	#print("dead: ", id)
	remove_object(id, player == 0)

func remove_object(id: int, color: bool) -> void:
	if color == false:
		if red_table[id] != null:
			var unit_instance = red_table[id]["instance"]
			
			if is_instance_valid(unit_instance):
				unit_instance.queue_free()
			
			red_table[id] = null
			#print("Object with ID", id, " of color red removed successfully.")
		#else:
			#print("Object with ID", id, " of color red not found.")
	else:
		if blue_table[id] != null:
			var unit_instance = blue_table[id]["instance"]
			for item in selected:
				if item["collider"] == unit_instance:
					selected.erase(item)
					break
			
			if is_instance_valid(unit_instance):
				unit_instance.queue_free()
			
			blue_table[id] = null
			#print("Object with ID", id, " of color blue removed successfully.")
		#else:
			#print("Object with ID", id, " of color blue not found.")

func change_position(player : int, id : int, new_position : Vector2) -> void:
	move_unit(id, new_position, player == 0)

func move_unit(unit_id: int, new_position: Vector2, color: bool):
	var unit_data = get_by_id(unit_id, color)
	if unit_data != null:
		var current_position = unit_data["position"]
		unit_data["instance"].change_position(current_position, new_position)
		unit_data["position"] = new_position
		#print("unit ", unit_id, " of color ", color, " changed position to", new_position)
		

func change_hp(player : int, id : int, hp : int) -> void:
	change_health(id, player == 0, hp)

func change_health(id: int, color: bool, value: int) -> void:
	var unit_data = get_by_id(id, color)
	if unit_data == null:
		return
	unit_data["instance"].change_health(value)
	
	
func check_and_add_unit_1_on_pressed(event):
	button_pressed = true
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if get_resource_amount() >= unit_1_price:
			var coords = $Map.get_global_mouse_position()
			var coords_window = event.global_position
			#print(coords, coords_window, offset)
			if coords_window.x < offset:
				#add_unit1(coords, id_num, player_color)
				Client.summon(Utils.EntityType.WORKER, coords)
		#else:
			#print("you do not have enough resource")
	button_pressed = false


func check_and_add_unit_2_on_pressed(event):
	button_pressed = true
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if get_resource_amount() >= unit_2_price:
			var coords = $Map.get_global_mouse_position()
			var coords_window = event.global_position
			if coords_window.x < offset:
				#add_unit2(coords, id_num, player_color)
				Client.summon(Utils.EntityType.PENTAGON, coords)
		#else:
			#print("you do not have enough resource")
	button_pressed = false
	
	
func check_and_add_unit_3_on_pressed(event):
	button_pressed = true
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if get_resource_amount() >= unit_3_price:
			var coords = $Map.get_global_mouse_position()
			var coords_window = event.global_position
			if coords_window.x < offset:
				#add_unit3(coords, id_num, player_color)
				Client.summon(Utils.EntityType.TRIANGLE, coords)
		#else:
			#print("you do not have enough resource")
	button_pressed = false
	
	
func check_and_add_unit_4_on_pressed(event):
	button_pressed = true
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if get_resource_amount() >= unit_4_price:
			var coords = $Map.get_global_mouse_position()
			var coords_window = event.global_position
			if coords_window.x < offset:
				#add_unit4(coords, id_num, player_color)
				Client.summon(Utils.EntityType.SQUARE, coords)
		#else:
			#print("you do not have enough resource")
	button_pressed = false
	
	
func check_and_add_main_base_on_pressed(event):
	button_pressed = true
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if get_resource_amount() >= main_base_price:
			var coords = $Map.get_global_mouse_position()
			var coords_window = event.global_position
			if coords_window.x < offset:
				#add_main_base(coords, player_color)
				Client.build(Utils.EntityType.MAIN_BASE, coords)
			base_exists = true
		#else:
			#print("you do not have enough resource")
	button_pressed = false
	main_base_button.toggle_mode = false
	
	
func check_and_add_building_2_on_pressed(event, unit_type):
	button_pressed = true
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var coords = $Map.get_global_mouse_position()
		var coords_window = event.global_position
		if coords_window.x < offset:
			#add_building_2(coords, id_num, player_color, unit_type)
			if unit_type == 1 and get_resource_amount() >= building_2_1_price:
				Client.build(Utils.EntityType.MINE_YES, coords);
				unit_1_base_exists = true
			elif unit_type == 2 and get_resource_amount() >= building_2_2_price:
				Client.build(Utils.EntityType.PENTAGON_YES, coords);
				unit_2_base_exists = true
			elif unit_type == 3 and get_resource_amount() >= building_2_3_price:
				Client.build(Utils.EntityType.TRIANGLE_YES, coords);
				unit_3_base_exists = true
			elif unit_type == 4 and get_resource_amount() >= building_2_4_price:
				Client.build(Utils.EntityType.SQUARE_YES, coords);
				unit_4_base_exists = true
		#else:
			#print("you do not have enough resource")
	button_pressed = false
	
	
func display_buttons():
	if base_exists == false:
		unit_1_button.disabled = true
		unit_2_button.disabled = true
		unit_3_button.disabled = true
		unit_4_button.disabled = true
		main_base_button.disabled = false
		unit_1_building_button.disabled = true
		unit_2_building_button.disabled = true
		unit_3_building_button.disabled = true
		unit_4_building_button.disabled = true
	else:
		unit_1_button.disabled = false
		unit_2_button.disabled = false
		unit_3_button.disabled = false
		unit_4_button.disabled = false
		main_base_button.disabled = true
		unit_1_building_button.disabled = false
		unit_2_building_button.disabled = false
		unit_3_building_button.disabled = false
		unit_4_building_button.disabled = false
		
	#if unit_1_base_exists == false:
		#unit_1_button.disabled = true
	#else:
		#unit_1_button.disabled = false
		
	if unit_2_base_exists == false:
		unit_2_button.disabled = true
	else:
		unit_2_button.disabled = false
		
	if unit_3_base_exists == false:
		unit_3_button.disabled = true
	else:
		unit_3_button.disabled = false
		
	if unit_4_base_exists == false:
		unit_4_button.disabled = true
	else:
		unit_4_button.disabled = false
