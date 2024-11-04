extends Node

@onready var server_ip = $ConnectButton/ServerIpInput
@onready var port = $ConnectButton/PortInput

func _on_connect_button_pressed() -> void:
	if Server.connected:
		Server.send_message("Hello server, it's me client!")
	else:
		Server.connect_to_server(server_ip.text, port.text.to_int())
