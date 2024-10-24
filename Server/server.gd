extends Node

signal send_message(message : String)
signal send_message_id(id : int, message : String)

var network

var client1_id : int = -1
var client2_id : int = -1

func _ready() -> void:
	#OS.read_string_from_stdin()
	network = get_node("../Network")
	send_message.connect(network._send_message)
	send_message_id.connect(network._send_message_id)
	
	multiplayer.peer_connected.connect(self._on_client_connect)
	multiplayer.peer_disconnected.connect(self._on_client_disconnect)
	
	var server = ENetMultiplayerPeer.new()
	if server.create_server(8080, 2) == OK:
		print("Server is running on port 8080")
	else:
		printerr("Something went wrong, unable to cerate a server")
		get_tree().quit()
	multiplayer.multiplayer_peer = server

func _on_client_connect(clientID : int) -> void:
	if client1_id == -1:
		client1_id = clientID
		send_message_id.emit(client1_id, "You connected as the first player, id: " + str(client1_id))
	else:
		client2_id = clientID
		send_message_id.emit(client2_id, "You connected as the second player, id: " + str(client2_id))
		send_message_id.emit(client2_id, "First player id: " + str(client1_id))
		await get_tree().create_timer(1).timeout
		send_message_id.emit(client1_id, "Second player connected, id: " + str(client2_id))
	print("Client connected, id: " + str(clientID))

func _on_client_disconnect(clientID : int) -> void:
	if client1_id == clientID:
		client1_id = -1
	else:
		client2_id = -1
	print("Client disconnected, id: " + str(clientID))
