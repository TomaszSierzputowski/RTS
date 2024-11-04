extends Node

#Reading from server
func _process(_delta: float) -> void:
	if not connected:
		return
	tls.poll() 
	if tls.get_status() != StreamPeerTLS.STATUS_CONNECTED:
		return
	while tls.get_available_bytes() > 0:
		readTLS()

func readTLS() -> Error:
	var msgType : int = tls.get_u8()
	match msgType:
		Utils.MessageType.JUST_STRING:
			var msg : String = tls.get_string()
			print("tls: ", msg)
		
		Utils.MessageType.ERROR_TO_FEW_BYTES:
			print("Server send back error TO_FEW_BYTES")
		
		Utils.MessageType.ERROR_UNEXISTING_MESSAGE_TYPE:
			print("Server send back error UNEXISTING_MESSAGE_TYPE")
		
		_:
			tls.put_u8(Utils.MessageType.ERROR_UNEXISTING_MESSAGE_TYPE)
			print("MessageType not exists")
			return ERR_BUG
	
	return OK

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
	var i : int = 2
	for c in login.to_ascii_buffer():
		i += 1
		packet.encode_u8(i, c)
	for c in password.to_ascii_buffer():
		i += 1
		packet.encode_u8(i, c)
	for c in salt.to_ascii_buffer():
		i += 1
		packet.encode_u8(i, c)
	tls.put_data(packet)
	return await tls.get_u8()

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
