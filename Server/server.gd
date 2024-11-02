extends Node

var client1_id : int = -1
var client2_id : int = -1

var map_size = Vector2()
var walkable_map = []

var characters ={}
var character_id_counter = 0

var buildings = {}
var building_id_counter = 0

var player_resoures = {}

func _ready() -> void:
	#OS.read_string_from_stdin()
	multiplayer.peer_connected.connect(self._on_client_connect)
	multiplayer.peer_disconnected.connect(self._on_client_disconnect)
	
	var server = ENetMultiplayerPeer.new()
	if server.create_server(8080, 2) == OK:
		print("Server is running on port 8080")
	else:
		printerr("Something went wrong, unable to cerate a server")
		get_tree().quit()
	multiplayer.multiplayer_peer = server
	
	load_map_from_file("res://Server/map.json")
	

func _on_client_connect(clientID : int) -> void:
	if client1_id == -1:
		client1_id = clientID
		Network._send_message_id(client1_id, "You connected as the first player, id: " + str(client1_id))
	else:
		client2_id = clientID
		Network._send_message_id(client2_id, "You connected as the second player, id: " + str(client2_id))
		Network._send_message_id(client2_id, "First player id: " + str(client1_id))
		Network._send_message_id(client1_id, "Second player connected, id: " + str(client2_id))
	print("Client connected, id: " + str(clientID))

func _on_client_disconnect(clientID : int) ->void:
	if client1_id == clientID:
		client1_id = -1
	else:
		client2_id = -1
	print("Client disconnected, id: " + str(clientID))
	
func load_map_from_file(file_path):
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
	
func can_spawn_character_at_position(position):
	var x = int(position.x)
	var y = int(position.y)
	
	if x < 0 or x >= map_size.x or y < 0 or y >= map_size.y:
		return false
	if walkable_map[y][x] != 0:
		return false
	for character in characters.values():
		if character["position"] == position:
			return false
	for building in buildings.values():
		if building["position"] == position:
			return false
	return true

func can_place_building_at_position(position):
	var x = int(position.x)
	var y = int(position.y)
	
	if x < 0 or x >= map_size.x or y < 0 or y >= map_size.y:
		return false
	if walkable_map[y][x] != 0:
		return false
	for building in buildings.values():
		if building["position"] == position:
			return false
	return true

func create_character(start_position, owner_id):
	if can_spawn_character_at_position(start_position):
		var character_id = character_id_counter
		character_id_counter += 1
		
		var character_data = {
			"id": character_id,
			"position": start_position,
			"speed": 100,
			"health":100,
			"owner_id": owner_id
		}
		characters[character_id] = character_data
		emit_signal("character_created", character_id, owner_id, start_position)  # Emitowanie sygnału utworzenia postaci
		print("Gracz o ID:",owner_id," stworzyl nowa postac o ID:", character_id," na pozycji:", start_position)
		
		return character_id
	else:
		print("Gracz o ID:",owner_id," nie moze utworzyc postac na pozycji:", start_position)
		return 
	
func create_building(start_position, owner_id):
	if can_place_building_at_position(start_position):
		var building_id = building_id_counter
		building_id += 1
		
		var building_data = {
			"id": building_id,
			"position": start_position,
			"owner_id": owner_id
		}
		
		buildings[building_id] = building_data
		
		emit_signal("building_created", building_id, owner_id, start_position)  # Emitowanie sygnału utworzenia postaci
		print("Gracz o ID:",owner_id," stworzyl nowy budynek o ID:", building_id," na pozycji:", start_position)
		
		return building_id
	else:
		print("Gracz o ID:",owner_id," nie moze utworzyc budynku na pozycji:", start_position)
		return 
	
func add_resources(player_id: int, resource_type: String, amount: int) -> void:
	if player_id in player_resoures:
		player_resoures[player_id][resource_type] += amount
		var new_amount = player_resoures[player_id][resource_type]
		emit_signal("resources_changed", player_id, resource_type, new_amount)
		print("Gracz o ID:",player_id," zwiekszyl zasob:",resource_type," o:",amount, "jego obecny stan:",player_resoures[player_id][resource_type])
	else:
		print("Gracz o ID:",player_id, " nie istneje")

func deduct_resources(player_id: int, resource_type: String, amount: int) -> bool:
	if player_id in player_resoures and player_resoures[player_id][resource_type] >= amount:
		player_resoures[player_id][resource_type] -= amount
		var new_amount = player_resoures[player_id][resource_type]
		emit_signal("resources_changed", player_id, resource_type, new_amount)
		print("Gracz o ID:",player_id," pomniejszony zosob:",resource_type," o:",amount," lacznie ma",player_resoures[player_id][resource_type])
		return true
	else:
		print("Gracz o ID:", player_id," nie istnieje lub nie ma wystarczajacej liczby zasobow")
		return false

func get_resources(player_id: int) -> Dictionary:
	if player_id in player_resoures:
		return player_resoures[player_id]
	else:
		print("Gracz o ID:",player_id, "nie zostal znaleziony")
		return {}
