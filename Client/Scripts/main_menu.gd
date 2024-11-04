extends Node

@onready var server_ip = $ConnectButton/ServerIpInput
@onready var port = $ConnectButton/PortInput

func _on_connect_button_pressed() -> void:
	if Client.connected:
		#Client.send_message("Hello server, it's me client!")
		#Client.send_test()
		var response : int = await Client.sign_up("test", "test12")
		match response:
			Utils.MessageType.RESPONSE_OK:
				print("Account successfully created")
			Utils.MessageType.ERROR_TO_FEW_BYTES:
				print("Server send back error TO_FEW_BYTES")
			Utils.MessageType.ERROR_LOGIN_ALREADY_EXISTS:
				print("Login already exists")
			Utils.MessageType.ERROR_INVALID_LOGIN:
				print("Invalid login")
			Utils.MessageType.ERROR_INVALID_HASHED_PASSWORD:
				print("Invalid hashed password")
			Utils.MessageType.ERROR_INVALID_SALT:
				print("Invalid salt")
			_:
				print("Unexpected server response: ", response)
	else:
		Client.connect_to_server(server_ip.text, port.text.to_int())
