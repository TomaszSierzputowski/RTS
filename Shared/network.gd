extends Node

@rpc("any_peer")
func send_message(message : String) -> void:
	print("Received message: " + message)

func _send_message(message : String) -> void:
	send_message.rpc(message)
