extends Node

signal response()
var err_no : Error

signal sign_up(login : String, password : String)
signal sign_in(login : String, password : String)

@rpc("any_peer", "call_remote", "reliable")
func r(err : Error) -> void:
	err_no = err
	response.emit()

func respond(err : Error) -> void:
	r.rpc(err)

func respond_id(id : int, err : Error) -> void:
	r.rpc_id(id, err)

@rpc("any_peer", "call_remote", "reliable")
func sm(packet : PackedByteArray) -> void:
	print("Received message: " + Serializer.deserialize_string(packet))

func _send_message(message : String) -> void:
	sm.rpc(Serializer.serialize_string(message))

func _send_message_id(id : int, message : String) -> void:
	sm.rpc_id(id, Serializer.serialize_string(message))

@rpc("any_peer", "call_remote", "reliable")
func su(packet : PackedByteArray) -> void:
	var login_password : Array[String] = Serializer.deserialize_strings(packet)
	sign_up.emit(login_password[0], login_password[1])

func _sign_up(login : String, password : String) -> void:
	su.rpc(Serializer.serialize_strings([login, password]))

@rpc("any_peer", "call_remote", "reliable")
func si(packet : PackedByteArray) -> void:
	var login_password : Array[String] = Serializer.deserialize_strings(packet)
	sign_in.emit(login_password[0], login_password[1])

func _sign_in(login : String, password : String) -> void:
	si.rpc(Serializer.serialize_strings([login, password]))
