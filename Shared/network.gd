extends Node

@rpc("any_peer")
func sm(packet : PackedByteArray) -> void:
	var size : int = packet[0]
	packet.remove_at(0)
	packet = packet.decompress(size)
	var message : String = packet.get_string_from_ascii()
	print("Received message: " + message)

func _send_message(message : String) -> void:
	sm.rpc(serialize_string(message))

func _send_message_id(id : int, message : String) -> void:
	sm.rpc_id(id, serialize_string(message))

func serialize_string(string : String) -> PackedByteArray:
	var txt : PackedByteArray = string.to_ascii_buffer()
	var packet : PackedByteArray
	packet.append(txt.size())
	txt = txt.compress()
	packet.append_array(txt)
	return packet
