extends Node

signal send_message(message : String)

var network

var client1_id : int = -1
var client2_id : int = -1

func _ready() -> void:
	print("This is a server")
	network = get_node("../Network")
	send_message.connect(network._send_message)
	
	multiplayer.peer_connected.connect(self._on_client_connect)
	multiplayer.peer_disconnected.connect(self._on_client_disconnect)
	
	var server = ENetMultiplayerPeer.new()
	server.create_server(8080, 2)
	multiplayer.multiplayer_peer = server

func _on_client_connect(clientID : int) -> void:
	if client1_id == -1:
		client1_id = clientID
	else:
		client2_id = clientID
	print("Client connected, id: " + str(clientID))
	send_message.emit("Client connected, id: " + str(clientID))

func _on_client_disconnect(clientID : int) -> void:
	if client1_id == clientID:
		client1_id = -1
	else:
		client2_id = -1
	print("Client disconnected, id: " + str(clientID))
