# GameSession.gd
extends Node

class_name GameSession

# Dwóch graczy w sesji gry
var player1: Player
var player2: Player

# Mapa gry
var game_map: Node
# Ścieżka do pliku sceny mapy
var map_scene_path = preload("res://Server/Game/map/map.tscn")

#Ścieżki do plików scen jednostek
var combatUnit_1 = preload("res://Server/Game/Units/Player1/Scenes/CombatUnit_1.tscn")
var workerunit_1 = preload("res://Server/Game/Units/Player1/Scenes/WorkerUnit_1.tscn")
var building_1 = preload("res://Server/Game/Units/Player1/Scenes/Building_1.tscn")

var combatUnit_2 = preload("res://Server/Game/Units/Player2/Scenes/CombatUnit_2.tscn")
var workerunit_2 = preload("res://Server/Game/Units/Player2/Scenes/WorkerUnit_2.tscn")
var building_2 = preload("res://Server/Game/Units/Player2/Scenes/Building_2.tscn")

# Inicjalizacja sesji gry
func _ready():
	# Inicjalizacja graczy
	player1 = Player.new()
	player2 = Player.new()
	
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
		

	
# Funkcja dodająca jednostkę do mapy
func add_unit_to_map(unit: Node, player: Player, position: Vector2):
	if not is_valid(position) and is_area_clear(position):
		unit.position = position
		player.add_unit(unit)
		if unit in player.units:
			var unit_name = unit.name
			game_map.add_child(unit)
			unit.name = unit_name

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
		point = tilemap.local_to_map(point)
		var cell_id = tilemap.get_cell_source_id(point)
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
			if child.position.distance_to(new_point) <= 15 :
				return false
	return true
	
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var target_position = game_map.get_global_mouse_position()
			target_position.x+=2000
			target_position.y-=7000
			if not is_valid(target_position) and is_area_clear(target_position):
				var unit_instance = combatUnit_1.instantiate()
				add_unit_to_map(unit_instance,player1,target_position)

		elif event.button_index == MOUSE_BUTTON_RIGHT:
			var target_position = game_map.get_global_mouse_position()
			target_position.x+=2000
			target_position.y-=7000
			if not is_valid(target_position) and is_area_clear(target_position):
				var unit_instance = combatUnit_2.instantiate()
				add_unit_to_map(unit_instance,player2,target_position)

	if event is InputEventKey:
		if Input.is_action_just_pressed("building_1"):
			var target_position = game_map.get_global_mouse_position()
			target_position.x+=2000
			target_position.y-=7000
			if not is_valid(target_position) and is_area_clear(target_position) :
				var unit_instance = building_1.instantiate()
				add_unit_to_map(unit_instance,player1,target_position)
		elif Input.is_action_just_pressed("Building_2"):
			var target_position = game_map.get_global_mouse_position()
			target_position.x+=2000
			target_position.y-=7000
			if not is_valid(target_position) and is_area_clear(target_position):
				var unit_instance = building_2.instantiate()
				add_unit_to_map(unit_instance,player2,target_position)
		elif Input.is_action_just_pressed("worker_1"):
			var target_position = game_map.get_global_mouse_position()
			target_position.x+=2000
			target_position.y-=7000
			if not is_valid(target_position) and is_area_clear(target_position):
				var unit_instance = workerunit_1.instantiate()
				unit_instance.player = player1
				add_unit_to_map(unit_instance,player1,target_position)
		elif Input.is_action_just_pressed("worker_2"):
			var target_position = game_map.get_global_mouse_position()
			target_position.x+=2000
			target_position.y-=7000
			if not is_valid(target_position) and is_area_clear(target_position):
				var unit_instance = workerunit_2.instantiate()
				unit_instance.player = player2
				add_unit_to_map(unit_instance,player2,target_position)
# Przykład użycia:
# var session = GameSession.new()
# session._ready()
# var unit = Node2D.new()
# session.add_unit_to_map(unit, session.player1, Vector2(100, 100))
