extends Node

@onready var server_ip = $ServerIpInput

func _on_test_button_pressed() -> void:
	print("trying to connect...")
	
	var client = ENetMultiplayerPeer.new()
	client.create_client(server_ip.text, 8080)
	multiplayer.multiplayer_peer = client
