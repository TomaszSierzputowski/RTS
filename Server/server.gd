extends Node

func _ready() -> void:
	print("This is a server")
	multiplayer.peer_connected.connect(self._on_client_connect)
	multiplayer.peer_disconnected.connect(self._on_client_disconnect)
	
	var server = ENetMultiplayerPeer.new()
	server.create_server(8080, 2)
	multiplayer.multiplayer_peer = server

func _on_client_connect(clientID : int) -> void:
	print("Client connected, id: " + str(clientID))

func _on_client_disconnect(clientID) -> void:
	print("Client disconnected, id: " + str(clientID))
