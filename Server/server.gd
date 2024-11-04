extends Node

var udp : UDPServer = UDPServer.new()
var udps : Array[PacketPeerUDP]

var tcp : TCPServer = TCPServer.new()
var tcps : Array[StreamPeerTLS]

func _ready() -> void:
	udp.listen(8080)
	tcp.listen(8080)
	print("server is listening on port 8080")
	randomize()

func _process(_delta : float) -> void:
	while tcp.is_connection_available():
		var peer : StreamPeerTCP = tcp.take_connection()
		print("someone is trying to connect")
		
		while peer.get_status() == StreamPeerTCP.Status.STATUS_CONNECTING:
			OS.delay_msec(1)
			var poll_err := peer.poll()
			if poll_err != OK:
				print("Failed to poll")
		
		if peer.get_status() != StreamPeerTCP.Status.STATUS_CONNECTED:
			print("TCP Connection error status: ", tcp.get_status())
		
		print("TCP connected")
		
		OS.delay_msec(10)
		
		var tls : StreamPeerTLS = StreamPeerTLS.new()
		var tls_err : Error
		
		tls_err = await tls.accept_stream(peer, TLSOptions.server(load("res://Server/key.key"), load("res://Shared/cert.crt")))
		
		if tls_err != OK:
			print("TLS accept error: ", tls_err)
		
		while tls.get_status() == StreamPeerTLS.Status.STATUS_HANDSHAKING:
			print("still handshaking")
			OS.delay_msec(1)
			tls.poll()
		if tls.get_status() != StreamPeerTLS.Status.STATUS_CONNECTED:
			print("TLS Connection error status: ", tls.get_status())
		
		tcps.append(tls)
		print("TLS connected")
	
	for peer in tcps:
		peer.poll()
		var status : StreamPeerTLS.Status = peer.get_status()
		if status == StreamPeerTLS.Status.STATUS_HANDSHAKING:
			continue
		if status == StreamPeerTLS.STATUS_DISCONNECTED or status == StreamPeerTLS.STATUS_ERROR:
			tcps.erase(peer)
			continue
		var bytes : int = peer.get_available_bytes()
		while bytes > 0:
			readTLS(peer, bytes)
			bytes = peer.get_available_bytes()
	
	udp.poll()
	while udp.is_connection_available():
		var peer: PacketPeerUDP = udp.take_connection()
		udps.append(peer)
		print("UDP connected")
	
	for peer in udps:
		while peer.get_available_packet_count() > 0:
			print("udp: ", peer.get_packet().get_string_from_ascii())

var salt_len : int = Utils.salt_len()
func readTLS(peer : StreamPeerTLS, bytes : int) -> Error:
	var msgType : int = peer.get_u8()
	match msgType:
		Utils.MessageType.TEST_BYTE_BY_BYTE:
			print("byte by byte")
			var err_pac = peer.get_partial_data(15)
			var err : Error = err_pac[0]
			var packet : PackedByteArray = err_pac[1]
			print(packet.size())
			print(packet)
		
		Utils.MessageType.SIGN_UP:
			if bytes < 3:
				if bytes > 1: peer.get_partial_data(bytes - 1)
				peer.put_u8(Utils.MessageType.ERROR_TO_FEW_BYTES)
				return ERR_INVALID_DATA
			var login_len : int = peer.get_u8()
			var pass_len : int = peer.get_u8()
			if bytes < 3 + login_len + pass_len + salt_len:
				if bytes > 3: peer.get_partial_data(bytes - 3)
				peer.put_u8(Utils.MessageType.ERROR_TO_FEW_BYTES)
				return ERR_INVALID_DATA
			peer.put_u8(sign_up(peer.get_string(login_len), peer.get_string(pass_len), peer.get_string(salt_len)))
		
		Utils.MessageType.JUST_STRING:
			var msg : String = peer.get_string()
			print("tls: ", msg)
			peer.put_u8(Utils.MessageType.JUST_STRING)
			peer.put_string("Received message: \"" + msg + "\"")
		
		Utils.MessageType.ERROR_UNEXISTING_MESSAGE_TYPE:
			print("Client send back error")
		
		_:
			peer.put_u8(Utils.MessageType.ERROR_UNEXISTING_MESSAGE_TYPE)
			if bytes > 1: peer.get_partial_data(bytes - 1)
			print("MessageType not exists")
			return ERR_BUG
	
	return OK

func sign_up(login : String, password : String, salt : String) -> Utils.MessageType:
	var p : float = randf()
	if p <= 0.2:
		print("Creating account: login: ", login, ", password: ", password, ", salt: ", salt)
		return Utils.MessageType.RESPONSE_OK
	elif p <= 0.4:
		print("Login already exists")
		return Utils.MessageType.ERROR_LOGIN_ALREADY_EXISTS
	elif p <= 0.6:
		print("Invalid login")
		return Utils.MessageType.ERROR_INVALID_LOGIN
	elif p <= 0.8:
		print("Invalid hashed password")
		return Utils.MessageType.ERROR_INVALID_HASHED_PASSWORD
	else:
		print("Invalid salt")
		return Utils.MessageType.ERROR_INVALID_SALT
