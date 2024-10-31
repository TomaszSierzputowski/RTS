extends Node

var client1_id : int = -1
var client2_id : int = -1

func _ready() -> void:
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
		Network._send_message_id(client1_id, "You connected as the first player, id: " + str(client1_id))
	else:
		client2_id = clientID
		Network._send_message_id(client2_id, "You connected as the second player, id: " + str(client2_id))
		Network._send_message_id(client2_id, "First player id: " + str(client1_id))
		Network._send_message_id(client1_id, "Second player connected, id: " + str(client2_id))
	print("Client connected, id: " + str(clientID))

func _on_client_disconnect(clientID : int) -> void:
	if client1_id == clientID:
		client1_id = -1
	else:
		client2_id = -1
	print("Client disconnected, id: " + str(clientID))
