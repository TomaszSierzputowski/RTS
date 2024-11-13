extends Node

var map_size = Vector2()
var walkable_map = []
var characters = [] 
var buildings = []  
var player_resources = {}
var character_id_counter = 0
var building_id_counter = 0

signal character_created(character_id, owner_id, position)
signal building_created(building_id, owner_id, position)
signal resources_changed(player_id, resource_type, new_amount)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func load_map_from_file(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file != null:
		var json_data = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(json_data)

		if result == OK:
			var data = json.get_data()
			map_size = Vector2(data["map_size"]["width"], data["map_size"]["height"])
			walkable_map = data["walkable_map"]
			print("Mapa zaladowana z pliku:", file_path)
		else:
			print("Blad podczas parsowania JSON:", result)
		file.close()
	else:
		print("Nie udalo sie otworzyc pliku:", file_path)


func can_spawn_character_at_position(position: Vector2) -> bool:
	var x = int(position.x)
	var y = int(position.y)
	if x < 0 or x >= map_size.x or y < 0 or y >= map_size.y:
		return false
	if walkable_map[y][x] != 0:
		return false
	for character in characters:
		if character.is_at_position(position):
			return false
	for building in buildings.values():
		if building["position"] == position:
			return false
	return true

func can_place_building_at_position(position: Vector2, size: Vector2) -> bool:
	var x_start = int(position.x)
	var y_start = int(position.y)
	var x_end = x_start + int(size.x)
	var y_end = y_start + int(size.y)

	if x_end > map_size.x or y_end > map_size.y:
		return false

	for y in range(y_start, y_end):
		for x in range(x_start, x_end):
			if walkable_map[y][x] != 0:
				return false

	for building in buildings:
		for y in range(y_start, y_end):
			for x in range(x_start, x_end):
				if building.is_at_position(Vector2(x, y)):
					return false

	return true

func create_character(start_position: Vector2, owner_id: int) -> int:
	if can_spawn_character_at_position(start_position):
		var character_id = character_id_counter
		character_id_counter += 1
		var character = Character.new(character_id, start_position, owner_id)
		characters.append(character)
		emit_signal("character_created", character_id, owner_id, start_position)
		print("Gracz o ID:", owner_id, " stworzyl nowa postac o ID:", character_id, " na pozycji:", start_position)
		return character_id
	else:
		print("Gracz o ID:", owner_id, " nie moze utworzyc postac na pozycji:", start_position)
		return -1

func create_building(start_position: Vector2, owner_id: int, size: Vector2) -> int:
	if can_place_building_at_position(start_position, size):
		var building_id = building_id_counter
		building_id_counter += 1
		var building = Building.new(building_id, start_position, owner_id, size)
		buildings.append(building)
		emit_signal("building_created", building_id, owner_id, start_position)
		print("Gracz o ID:", owner_id, " stworzyl nowy budynek o ID:", building_id, " na pozycji:", start_position)
		return building_id
	else:
		print("Gracz o ID:", owner_id, " nie moze utworzyc budynku na pozycji:", start_position)
		return -1

func add_resources(player_id: int, resource_type: String, amount: int) -> void:
	if player_id in player_resources:
		player_resources[player_id][resource_type] += amount
		var new_amount = player_resources[player_id][resource_type]
		emit_signal("resources_changed", player_id, resource_type, new_amount)
		print("Gracz o ID:", player_id, " zwiekszyl zasob:", resource_type, " o:", amount, "jego obecny stan:", player_resources[player_id][resource_type])
	else:
		print("Gracz o ID:", player_id, " nie istneje")

func deduct_resources(player_id: int, resource_type: String, amount: int) -> bool:
	if player_id in player_resources and player_resources[player_id][resource_type] >= amount:
		player_resources[player_id][resource_type] -= amount
		var new_amount = player_resources[player_id][resource_type]
		emit_signal("resources_changed", player_id, resource_type, new_amount)
		print("Gracz o ID:", player_id, " pomniejszony zasob:", resource_type, " o:", amount, " lacznie ma", player_resources[player_id][resource_type])
		return true
	else:
		print("Gracz o ID:", player_id, " nie istnieje lub nie ma wystarczajacej liczby zasobow")
		return false

func get_resources(player_id: int) -> Dictionary:
	if player_id in player_resources:
		return player_resources[player_id]
	else:
		print("Gracz o ID:", player_id, "nie zostal znaleziony")
		return {}
