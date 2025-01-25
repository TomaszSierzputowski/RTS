# GameSession.gd
extends Node

class_name GameSession

# Mapa gry
var game_map: Node
# Ścieżka do pliku sceny mapy
var map_scene_path = preload("res://Server/Game/map/map.tscn")

#Ścieżki do plików scen jednostek
var combatUnit = [preload("res://Server/Game/Units/Player1/Scenes/CombatUnit_1.tscn"), preload("res://Server/Game/Units/Player2/Scenes/CombatUnit_2.tscn")]
var workerunit = [preload("res://Server/Game/Units/Player1/Scenes/WorkerUnit_1.tscn"), preload("res://Server/Game/Units/Player2/Scenes/WorkerUnit_2.tscn")]
var building = [preload("res://Server/Game/Units/Player1/Scenes/Building_1.tscn"), preload("res://Server/Game/Units/Player2/Scenes/Building_2.tscn")]

var BaseBuilding = preload("res://Server/Game/Units/Player1/Building/Scenes/BaseBuilding_1.tscn")
var mineBuilding = preload("res://Server/Game/Units/Player1/Building/Scenes/MineBuilding_1.tscn")
var triangleBuilding = preload("res://Server/Game/Units/Player1/Building/Scenes/FastUnitFactory_1.tscn")
var squareBuilding = preload("res://Server/Game/Units/Player1/Building/Scenes/HeavyUnitFactory_1.tscn")
var pentagonBuilding = preload("res://Server/Game/Units/Player1/Building/Scenes/StandardUnitFactory_1.tscn")
var workerUnit = preload("res://Server/Game/Units/Player1/Units/Scenes/WorkerUnit_1.tscn")

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
			#unit = workerunit[player_num].instantiate()
			unit = workerUnit.instantiate()
			unit.player = players[player_num]
		Utils.EntityType.MAIN_BASE:
			#unit = building[player_num].instantiate()
			unit = BaseBuilding.instantiate()
		Utils.EntityType.MINE_YES:
			#unit = building[player_num].instantiate()
			unit = mineBuilding.instantiate()
		Utils.EntityType.TRIANGLE_YES:
			#unit = building[player_num].instantiate()
			unit = triangleBuilding.instantiate()
		Utils.EntityType.SQUARE_YES:
			#unit = building[player_num].instantiate()
			unit = squareBuilding.instantiate()
		Utils.EntityType.PENTAGON_YES:
			#unit = building[player_num].instantiate()
			unit = pentagonBuilding.instantiate()
# Funkcja dodająca jednostkę do mapy
#func add_unit_to_map(unit: Node, player_num: int, position: Vector2):
	if unit:
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
	
func is_valid(point: Vector2):
	
	var tilemap = game_map.get_node("TileMapLayer")
	if tilemap:
		point =tilemap.local_to_map(point)
		print(point)
		var cell_id = tilemap.get_cell_source_id(point)
		print(cell_id)
		if cell_id != 4 and cell_id != 1 and cell_id != -1:
			return false
	return true

func is_area_clear(point: Vector2) -> bool:
	var new_point = point
	for child in game_map.get_children():
		if child is StaticBody2D :
			if child.position.distance_to(new_point) <= 50 :
				return false
		if child is CharacterBody2D :
			if child.position.distance_to(new_point) <= 25 :
				return false
	return true
	
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var target_position = game_map.get_global_mouse_position()
			if not is_valid(target_position) and is_area_clear(target_position):
				summon(0,Utils.EntityType.CHARACTER,target_position)

		elif event.button_index == MOUSE_BUTTON_RIGHT:
			var target_position = game_map.get_global_mouse_position()
			if not is_valid(target_position) and is_area_clear(target_position):
				summon(1,Utils.EntityType.CHARACTER,target_position)

	if event is InputEventKey:
		if Input.is_action_just_pressed("building_1"):
			var target_position = game_map.get_global_mouse_position()
			if not is_valid(target_position) and is_area_clear(target_position) :
				summon(0,Utils.EntityType.BUILDING,target_position)
		elif Input.is_action_just_pressed("building_2"):
			var target_position = game_map.get_global_mouse_position()
			if not is_valid(target_position) and is_area_clear(target_position):
				summon(1,Utils.EntityType.BUILDING,target_position)
		elif Input.is_action_just_pressed("worker_1"):
			var target_position = game_map.get_global_mouse_position()
			if not is_valid(target_position) and is_area_clear(target_position):
				summon(0,Utils.EntityType.CHARACTER,target_position)
		elif Input.is_action_just_pressed("worker_2"):
			var target_position = game_map.get_global_mouse_position()
			if not is_valid(target_position) and is_area_clear(target_position):
				summon(0,Utils.EntityType.CHARACTER,target_position)

# Przykład użycia:
# var session = GameSession.new()
# session._ready()
# var unit = Node2D.new()
# session.add_unit_to_map(unit, session.player1, Vector2(100, 100))
