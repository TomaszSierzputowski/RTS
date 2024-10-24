extends Node

signal send_message(message : String)

@onready var server_ip = $ConnectButton/ServerIpInput
@onready var port = $ConnectButton/PortInput
var network : NetworkManager

func _ready() -> void:
	network = get_node("../Network")
	send_message.connect(network._send_message)

func _on_connect_button_pressed() -> void:
	print("trying to connect...")
	
	var client = ENetMultiplayerPeer.new()
	client.create_client(server_ip.text, int(port.text))
	multiplayer.multiplayer_peer = client
	
	await multiplayer.connected_to_server
	send_message.emit("Hello server, it's me client")
