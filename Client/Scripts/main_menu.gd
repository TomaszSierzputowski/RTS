extends Node

@onready var server_ip = $ConnectButton/ServerIpInput
@onready var port = $ConnectButton/PortInput

func _on_connect_button_pressed() -> void:
	print("trying to connect...")
	
	var client = ENetMultiplayerPeer.new()
	client.create_client(server_ip.text, int(port.text))
	multiplayer.multiplayer_peer = client
	
	await multiplayer.connected_to_server
	Net._send_message("Hello server, it's me client")
