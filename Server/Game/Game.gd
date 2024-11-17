extends Node

class_name Game

var map_size: Vector2 = Vector2()
var walkable_map: Array = []
var players: Array = []
var character_id_counter: int = 0
var building_id_counter: int = 0

signal game_initialized()
signal character_created(character_id: int, owner_id: int, position: Vector2)
signal building_created(building_id: int, owner_id: int, position: Vector2)
signal resources_changed(player_id: int, resource_type: String, new_amount: int)

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass

func start_new_game(map_path: String, player1_id: int, player2_id: int) -> void:
	# Wczytaj mapę
	load_map_from_file(map_path)
	
	# Utwórz dwóch graczy
	var player1 = Player.new(player1_id)
	var player2 = Player.new(player1_id)
	players.append(player1)
	players.append(player2)
	
	emit_signal("game_initialized")
	print("Nowa gra rozpoczęta! Dwóch graczy zostało stworzonych.")

func load_map_from_file(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_data = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(json_data)

		if result == OK:
			var data = json.get_data()
			map_size = Vector2(data["map_size"]["width"], data["map_size"]["height"])
			walkable_map = data["walkable_map"]
			print("Mapa załadowana z pliku:", file_path)
		else:
			print("Błąd podczas parsowania JSON:", result)
		file.close()
	else:
		print("Nie udało się otworzyć pliku:", file_path)

func get_player(player_id: int) -> Player:
	for player in players:
		if player.id == player_id:
			return player
	print("Gracz o ID:", player_id, "nie został znaleziony")
	return null

func handle_character_creation(owner_id: int, position: Vector2) -> int:
	var player = get_player(owner_id)
	if player:
		if can_spawn_character_at_position(position):
			var character_id = character_id_counter
			character_id_counter += 1
			player.add_character(Character.new(character_id, position, owner_id))
			emit_signal("character_created", character_id, owner_id, position)
			print("Postać ID:", character_id, "utworzona dla gracza ID:", owner_id)
			return character_id
		else:
			print("Nie można stworzyć postaci na pozycji:", position)
	return -1

func handle_building_creation(owner_id: int, position: Vector2, size: Vector2) -> int:
	var player = get_player(owner_id)
	if player:
		if can_place_building_at_position(position, size):
			var building_id = building_id_counter
			building_id_counter += 1
			player.add_building(Building.new(building_id, position,owner_id, size))
			emit_signal("building_created", building_id, owner_id, position)
			print("Budynek ID:", building_id, "utworzony dla gracza ID:", owner_id)
			return building_id
		else:
			print("Nie można stworzyć budynku na pozycji:", position)
	return -1

func can_spawn_character_at_position(position: Vector2) -> bool:
	if position.x < 0 or position.x >= map_size.x or position.y < 0 or position.y >= map_size.y:
		return false
	if walkable_map[int(position.y)][int(position.x)] != 0:
		return false
	for player in players:
		for character in player.characters:
			if character.is_at_position(position):
				return false
	return true

func can_place_building_at_position(position: Vector2, size: Vector2) -> bool:
	var x_end = int(position.x + size.x)
	var y_end = int(position.y + size.y)

	if x_end > map_size.x or y_end > map_size.y:
		return false

	for y in range(int(position.y), y_end):
		for x in range(int(position.x), x_end):
			if walkable_map[y][x] != 0:
				return false
			for player in players:
				for building in player.buildings:
					if building.is_at_position(Vector2(x, y)):
						return false

	return true
