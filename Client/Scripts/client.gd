extends Node

#Reading from server
func _process(_delta: float) -> void:
	if not connected:
		return
	tls.poll() 
	if tls.get_status() != StreamPeerTLS.STATUS_CONNECTED:
		return
	if waiting_for_response:
		return
	var bytes : int = tls.get_available_bytes()
	while bytes > 0:
		readTLS(bytes)
		bytes = tls.get_available_bytes()

func readTLS(bytes : int) -> Error:
	var msgType : int = tls.get_u8()
	match msgType:
		Utils.MessageType.JUST_STRING:
			var msg : String = tls.get_string()
			print("tls: ", msg)
		
		Utils.MessageType.ERROR_TO_FEW_BYTES:
			print("Server send back error TO_FEW_BYTES")
		
		Utils.MessageType.ERROR_UNEXISTING_MESSAGE_TYPE:
			print("Server send back error UNEXISTING_MESSAGE_TYPE")
		
		Utils.MessageType.SALT:
			if not waiting_for_salt:
				if bytes > 1: tls.get_partial_data(bytes - 1)
				tls.put_u8(Utils.MessageType.ERROR_UNEXPECTED_SALT)
				return ERR_DOES_NOT_EXIST
			if bytes < 1 + salt_len:
				if bytes > 1: tls.get_partial_data(bytes - 1)
				tls.put_u8(Utils.MessageType.ERROR_TO_FEW_BYTES)
				return ERR_INVALID_DATA
			continue_signing.emit(tls.get_string(salt_len))
		
		_:
			tls.put_u8(Utils.MessageType.ERROR_UNEXISTING_MESSAGE_TYPE)
			print("MessageType not exists")
			return ERR_BUG
	
	return OK

var waiting_for_response : bool = false
func wait_for_response() -> Utils.MessageType:
	waiting_for_response = true
	var response = await tls.get_u8()
	waiting_for_response = false
	return response

func send_test() -> void:
	var packet : PackedByteArray
	packet.resize(10)
	packet.encode_u8(0, Utils.MessageType.TEST_BYTE_BY_BYTE)
	packet.encode_u32(1, "Hello".length())
	var i := 4
	for c in "Hello".to_ascii_buffer():
		i += 1
		packet.encode_u8(i, c)
	tls.put_data(packet)

#Sending messages
func send_message(msg : String) -> Error:
	if not connected:
		return ERR_DOES_NOT_EXIST
	tls.poll()
	tls.put_u8(Utils.MessageType.JUST_STRING)
	tls.put_string(msg)
	tls.poll()
	if tls.get_status() != StreamPeerTLS.STATUS_CONNECTED:
		return ERR_CONNECTION_ERROR
	return OK

var salt_len : int = Utils.salt_len()
func sign_up(login : String, password : String, salt : String = "placeholder") -> int:
	var packet : PackedByteArray
	var login_len : int = login.length()
	var pass_len : int = password.length()
	packet.resize(3 + login_len + pass_len + salt_len)
	packet.encode_u8(0, Utils.MessageType.SIGN_UP)
	packet.encode_u8(1, login_len)
	packet.encode_u8(2, pass_len)
	var i : int = 3
	i = encode_string(packet, i, login)
	i = encode_string(packet, i, password)
	encode_string(packet, i, salt)
	tls.put_data(packet)
	return await wait_for_response()

signal continue_signing(salt : String)
var waiting_for_salt : bool = false
func sign_in(login : String, password : String) -> Utils.MessageType:
	var packet : PackedByteArray
	var login_len : int = login.length()
	packet.resize(2 + login_len)
	packet.encode_u8(0, Utils.MessageType.ASK_FOR_SALT)
	packet.encode_u8(1, login_len)
	encode_string(packet, 2, login)
	tls.put_data(packet)
	var response = await wait_for_response()
	if response != Utils.MessageType.RESPONSE_OK:
		return response
	waiting_for_salt = true
	var salt = await continue_signing
	waiting_for_salt = false
	var hashed_password = password
	var hash_len = hashed_password.length()
	packet.resize(2 + hash_len)
	packet.encode_u8(0, Utils.MessageType.HASHED_PASSWORD)
	packet.encode_u8(1, hash_len)
	encode_string(packet, 2, hashed_password)
	tls.put_data(packet)
	return await wait_for_response()

#Connecting TLS
var tcp : StreamPeerTCP
var tls : StreamPeerTLS
var connected := false
func connect_to_server(host : String, port : int) -> Error:
	if tls != null and (tls.get_status() == StreamPeerTLS.STATUS_HANDSHAKING or tls.get_status() == StreamPeerTLS.STATUS_CONNECTED):
		print("Client already connected to server")
		return ERR_ALREADY_EXISTS
	print("trying to connect")
	tls = StreamPeerTLS.new()
	if tcp != null:
		if tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			tcp.disconnect_from_host()
		tcp = null
	tcp = StreamPeerTCP.new()
	var tcp_connect_err := tcp.connect_to_host(host, port)
	if tcp_connect_err != OK:
		print("Failed to connect")
		return tcp_connect_err
	
	while tcp.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		OS.delay_msec(1)
		var poll_err := tcp.poll()
		if poll_err != OK:
			print("Failed to poll")
			return poll_err
	if tcp.get_status() != StreamPeerTCP.Status.STATUS_CONNECTED:
		print("TCP Connection error status: ", tcp.get_status())
		return ERR_CONNECTION_ERROR
	
	print("TCP connected")
	
	var tls_connect_err : Error = tls.connect_to_stream(tcp, "localhost", TLSOptions.client_unsafe(load("res://Shared/cert.crt")))
	if tls_connect_err != OK:
		print("Failed to tls connect")
		return tls_connect_err
	while tls.get_status() == StreamPeerTLS.Status.STATUS_HANDSHAKING:
		OS.delay_msec(1)
		tls.poll()
	if tls.get_status() != StreamPeerTLS.STATUS_CONNECTED:
		print("TLS Connection error status: ", tls.get_status())
		return ERR_CONNECTION_ERROR
	
	print("TLS connected")
	
	connected = true
	
	return OK

func encode_string(packet : PackedByteArray, byte_offset : int, string : String) -> int:
	for c in string.to_ascii_buffer():
		packet.encode_u8(byte_offset, c)
		byte_offset += 1
	return byte_offset
