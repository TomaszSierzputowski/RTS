# GameSession.gd
extends Node

class_name GameSession

# Mapa gry
var game_map: Node
# Ścieżka do pliku sceny mapy
var map_scene_path = preload("res://Server/Game/map/map.tscn")

var BaseBuilding = [preload("res://Server/Game/Player1/Building/Scenes/BaseBuilding_1.tscn"),preload("res://Server/Game/Player2/Building/Scenes/BaseBuilding_2.tscn")]
var mineBuilding = [preload("res://Server/Game/Player1/Building/Scenes/MineBuilding_1.tscn"),preload("res://Server/Game//Player2/Building/Scenes/MineBuilding_2.tscn")]
var triangleBuilding = [preload("res://Server/Game/Player1/Building/Scenes/FastUnitFactory_1.tscn"),preload("res://Server/Game/Player2/Building/Scenes/FastUnitFactory_2.tscn")]
var squareBuilding = [preload("res://Server/Game/Player1/Building/Scenes/HeavyUnitFactory_1.tscn"),preload("res://Server/Game/Player2/Building/Scenes/HeavyUnitFactory_2.tscn")]
var pentagonBuilding = [preload("res://Server/Game/Player1/Building/Scenes/StandardUnitFactory_1.tscn"),preload("res://Server/Game/Player2/Building/Scenes/StandardUnitFactory_2.tscn")]
var workerUnit = [preload("res://Server/Game/Player1/Units/Scenes/WorkerUnit_1.tscn"), preload("res://Server/Game/Player2/Units/Scenes/WorkerUnit_2.tscn")]
var square = [preload("res://Server/Game/Player1/Units/Scenes/StandardUnit_1.tscn"),preload("res://Server/Game/Player2/Units/Scenes/StandardUnit_2.tscn")]
var triangle = [preload("res://Server/Game/Player1/Units/Scenes/FastUnit_1.tscn"),preload("res://Server/Game/Player2/Units/Scenes/FastUnit_2.tscn")] 
var pentagon = [preload("res://Server/Game/Player1/Units/Scenes/StandardUnit_1.tscn"),preload("res://Server/Game/Player2/Units/Scenes/StandardUnit_2.tscn")]

var players : Array[Player]

signal game_sb_sig0(player : int, id : int, entity : Utils.EntityType, position : Vector2)
signal game_sb_sig1(player : int, id : int, entity : Utils.EntityType, position : Vector2)
var game_summoned_built : Array[Signal] = [game_sb_sig0, game_sb_sig1]
signal game_dd_sig0(player : int, id : int)
signal game_dd_sig1(player : int, id : int)
var game_died_destroyed : Array[Signal] = [game_dd_sig0, game_dd_sig1]
signal game_a_sig0(id : int, entity : Utils.EntityType, position : Vector2, hp : int)
signal game_a_sig1(id : int, entity : Utils.EntityType, position : Vector2, hp : int)
var game_appeared : Array[Signal] = [game_a_sig0, game_a_sig1]
signal game_d_sig0(id : int)
signal game_d_sig1(id : int)
var game_disappeared : Array[Signal] = [game_d_sig0, game_d_sig1]
signal game_pc_sig0(player : int, id : int, new_position : Vector2)
signal game_pc_sig1(player : int, id : int, new_position : Vector2)
var game_position_changed : Array[Signal] = [game_pc_sig0, game_pc_sig1]
signal game_hc_sig0(player : int, id : int, hp : int)
signal game_hc_sig1(player : int, id : int, hp : int)
var game_hp_changed : Array[Signal] = [game_hc_sig0, game_hc_sig1]

# Inicjalizacja sesji gry
func _ready():
	# Inicjalizacja graczy
	players.resize(2)
	players[0] = Player.new()
	players[1] = Player.new()
	
	# Ładowanie mapy gry
	load_map()
	print("Game session initialized")
	

# Funkcja ładująca mapę gry z pliku sceny
func load_map():
	var map_scene = map_scene_path
	if map_scene:
		game_map = map_scene.instantiate()
		add_child(game_map)
		print("Game map loaded")
	else:
		print("Failed to load game map")
		

func summon(player_num : int, character_type : Utils.EntityType, position : Vector2) -> void:
	var unit : Node
	match character_type:
		Utils.EntityType.WORKER:
			unit = workerUnit[player_num].instantiate()
			unit.player = players[player_num]
		Utils.EntityType.MAIN_BASE:
			unit = BaseBuilding[player_num].instantiate()
		Utils.EntityType.MINE_YES:
			unit = mineBuilding[player_num].instantiate()
		Utils.EntityType.TRIANGLE_YES:
			unit = triangleBuilding[player_num].instantiate()
		Utils.EntityType.SQUARE_YES:
			unit = squareBuilding[player_num].instantiate()
		Utils.EntityType.PENTAGON_YES:
			unit = pentagonBuilding[player_num].instantiate()
		Utils.EntityType.TRIANGLE:
			unit = triangle[player_num].instantiate()
		Utils.EntityType.SQUARE:
			unit = square[player_num].instantiate()
		Utils.EntityType.PENTAGON:
			unit = pentagon[player_num].instantiate()
# Funkcja dodająca jednostkę do mapy
#func add_unit_to_map(unit: Node, player_num: int, position: Vector2):
	if unit and can_place(player_num,character_type,position): #and is_valid(position):
		print("summoned: ", character_type)
		var player = players[player_num]
		unit.position = position
		player.add_unit(unit)
		if unit in player.units:
			var unit_name = unit.name
			game_map.add_child(unit)
			unit.name = unit_name
			#dużo na sztywno do zmiany
			# poinformowanie gracza 0
			game_summoned_built[0].emit(player_num, 0, character_type, position)
			# poinformowanie gracza 1
			game_summoned_built[1].emit(player_num, 0, character_type, position)
			print("Send info about summoning")

func get_cell_id(point: Vector2):
	var tilemap = game_map.get_node("TileMapLayer")
	if tilemap:
		point = tilemap.local_to_map(point)
		var cell_id = tilemap.get_cell_source_id(point)
		if cell_id != -1:
			return cell_id
	return -1

func can_place(player_num : int, character_type : Utils.EntityType,  position : Vector2) -> bool:
	var shape
	match character_type:
		Utils.EntityType.WORKER:
			shape = CircleShape2D.new()
			shape.radius = 15
		Utils.EntityType.MAIN_BASE:
			shape = CircleShape2D.new()
			shape.radius = 100
		Utils.EntityType.MINE_YES:
			shape = RectangleShape2D.new()
			shape.size = Vector2(100,100)
		Utils.EntityType.TRIANGLE_YES:
			shape = RectangleShape2D.new()
			shape.size = Vector2(100,100)
		Utils.EntityType.SQUARE_YES:
			shape = RectangleShape2D.new()
			shape.size = Vector2(100,100)
		Utils.EntityType.PENTAGON_YES:
			shape = RectangleShape2D.new()
			shape.size = Vector2(100,100)
		Utils.EntityType.TRIANGLE:
			shape = CircleShape2D.new()
			shape.radius = 15
		Utils.EntityType.SQUARE:
			shape = CircleShape2D.new()
			shape.radius = 15
		Utils.EntityType.PENTAGON:
			shape = CircleShape2D.new()
			shape.radius = 15
	
	if !is_valid(position) and is_area_clear(position,shape) and is_unit_in_range_of_building(player_num,character_type,position):
		return true
	return false
	
func is_valid(point: Vector2):
	
	var tilemap = game_map.get_node("TileMapLayer")
	if tilemap:
		point =tilemap.local_to_map(point)
		var cell_id = tilemap.get_cell_source_id(point)
		if cell_id != 4 and cell_id != 1 and cell_id != -1:
			return false
	return true
	

func is_area_clear(position: Vector2, shape: Shape2D)-> bool:
	var shape2
	for child in game_map.get_children():
		if child.has_method("get_class_name"):
			var classname = child.get_class_name()
			if classname == "Base":
				shape2 = CircleShape2D.new()
				shape2.radius = 100
				if shape.collide(Transform2D(0,position),shape2,Transform2D(0,child.global_position)):
					return false
			elif classname  in ["FastUnit","StandardUnit","HeavyUnit","WorkerUnit"]:
				shape2 = CircleShape2D.new()
				shape2.radius = 15
				if shape.collide(Transform2D(0,position),shape2,Transform2D(0,child.global_position)):
					return false
			elif classname in ["FastUnitFactory","StandardUnitFactory","HeavyUnitFactory","Mine"]:
				shape2 = RectangleShape2D.new()
				shape2.size = Vector2(100,100)
				if shape.collide(Transform2D(0,position),shape2,Transform2D(0,child.global_position)):
					return false
	return true

func is_unit_in_range_of_building(player_num : int, character_type : Utils.EntityType,  position : Vector2):
	if character_type not in [Utils.EntityType.TRIANGLE, Utils.EntityType.SQUARE, Utils.EntityType.PENTAGON]:
		return true
	for child in game_map.get_children():
		if child.has_method("get_class_name") and child.has_method("get_player_num"):
			var classname = child.get_class_name()
			var player_num_2 = child.get_player_num()-1
			match character_type:
				Utils.EntityType.TRIANGLE:
					if classname == "FastUnitFactory" and child.global_position.distance_to(position)<=200 and player_num == player_num_2:
						return true
				Utils.EntityType.SQUARE:
					if classname == "StandardUnitFactory" and child.global_position.distance_to(position)<=200 and player_num == player_num_2:
						return true
				Utils.EntityType.PENTAGON:
					if classname == "HeavyUnitFactory" and child.global_position.distance_to(position)<=200 and player_num == player_num_2:
						return true
			
	return false
	
func end_game() -> void:
	queue_free()
	
	
func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("MAIN_BASE_1"):
			var target_position = game_map.get_global_mouse_position()
			var shape = CircleShape2D.new()
			shape.radius = 100
			if can_place(0,Utils.EntityType.MAIN_BASE,target_position):
				summon(0,Utils.EntityType.MAIN_BASE, target_position)
		if Input.is_action_just_pressed("MAIN_BASE_2"):
			var target_position = game_map.get_global_mouse_position()
			var shape = CircleShape2D.new()
			shape.radius = 100
			if can_place(1,Utils.EntityType.MAIN_BASE,target_position):
				summon(1,Utils.EntityType.MAIN_BASE, target_position)
		if Input.is_action_just_pressed("MINE_1"):
			var target_position = game_map.get_global_mouse_position()
			var shape = RectangleShape2D.new()
			shape.size = Vector2(100,100)
			if can_place(0,Utils.EntityType.MINE_YES, target_position):
				summon(0,Utils.EntityType.MINE_YES, target_position)
		if Input.is_action_just_pressed("MINE_2"):
			var target_position = game_map.get_global_mouse_position()
			var shape = RectangleShape2D.new()
			shape.size = Vector2(100,100)
			if can_place(1,Utils.EntityType.MINE_YES, target_position):
				summon(1,Utils.EntityType.MINE_YES, target_position)
		if Input.is_action_just_pressed("TRAINGLE_B_1"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(0,Utils.EntityType.TRIANGLE_YES, target_position):
				summon(0,Utils.EntityType.TRIANGLE_YES, target_position)
		if Input.is_action_just_pressed("TRAINGLE_B_2"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(1,Utils.EntityType.TRIANGLE_YES, target_position):
				summon(1,Utils.EntityType.TRIANGLE_YES, target_position)
		if Input.is_action_just_pressed("SQUARE_B_1"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(0,Utils.EntityType.SQUARE_YES, target_position):
				summon(0,Utils.EntityType.SQUARE_YES, target_position)
		if Input.is_action_just_pressed("SQUARE_B_2"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(1,Utils.EntityType.SQUARE_YES, target_position):
				summon(1,Utils.EntityType.SQUARE_YES, target_position)
		if Input.is_action_just_pressed("PENTAGON_B_1"):
			var target_position = game_map.get_global_mouse_position()
			var shape = RectangleShape2D.new()
			shape.size = Vector2(100,100)
			if not is_valid(target_position) and is_area_clear(target_position,shape) :
				summon(0,Utils.EntityType.PENTAGON_YES, target_position)
		if Input.is_action_just_pressed("PENTAGON_B_2"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(1,Utils.EntityType.PENTAGON_YES, target_position):
				summon(1,Utils.EntityType.PENTAGON_YES, target_position)
		if Input.is_action_just_pressed("WORKER_1"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(0,Utils.EntityType.WORKER, target_position):
				summon(0,Utils.EntityType.WORKER, target_position)
		if Input.is_action_just_pressed("WORKER_2"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(1,Utils.EntityType.WORKER, target_position):
				summon(1,Utils.EntityType.WORKER, target_position)
		if Input.is_action_just_pressed("TRAINGLE_1"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(0,Utils.EntityType.TRIANGLE, target_position):
				summon(0,Utils.EntityType.TRIANGLE, target_position)
		if Input.is_action_just_pressed("TRAINGLE_2"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(1,Utils.EntityType.TRIANGLE, target_position):
				summon(1,Utils.EntityType.TRIANGLE, target_position)
		if Input.is_action_just_pressed("SQUARE_1"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(0,Utils.EntityType.SQUARE, target_position):
				summon(0,Utils.EntityType.SQUARE, target_position)
		if Input.is_action_just_pressed("SQUARE_2"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(1,Utils.EntityType.SQUARE, target_position):
				summon(1,Utils.EntityType.SQUARE, target_position)
		if Input.is_action_just_pressed("PENTAGON_1"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(0,Utils.EntityType.PENTAGON, target_position):
				summon(0,Utils.EntityType.PENTAGON, target_position)
		if Input.is_action_just_pressed("PENTAGON_2"):
			var target_position = game_map.get_global_mouse_position()
			if can_place(1,Utils.EntityType.PENTAGON, target_position):
				summon(1,Utils.EntityType.PENTAGON, target_position)
# Przykład użycia:
# var session = GameSession.new()
# session._ready()
# var unit = Node2D.new()
# session.add_unit_to_map(unit, session.player1, Vector2(100, 100))
