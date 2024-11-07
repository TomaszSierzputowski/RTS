extends Node

var udp : UDPServer = UDPServer.new()
const udp_port : int = 4443

var tcp : TCPServer = TCPServer.new()
const tcp_port : int = 4443

var sessions : Array[Account]
var waiting_for_authorization : Array[Account]
var authorisation_failed : Array[Account]
#var waiting_for_second_player : GameRoom

func _ready() -> void:
	tcp.listen(tcp_port)
	udp.listen(udp_port)
	print("server is listening on port ", tcp_port)
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
		
		sessions.append(Account.new(tls))
		print("TLS connected")
	
	for session in sessions:
		var peer := session.tls
		peer.poll()
		var status : StreamPeerTLS.Status = peer.get_status()
		if status == StreamPeerTLS.Status.STATUS_HANDSHAKING:
			continue
		if status == StreamPeerTLS.STATUS_DISCONNECTED or status == StreamPeerTLS.STATUS_ERROR:
			sessions.erase(session)
			continue
		var bytes : int = peer.get_available_bytes()
		while bytes > 0:
			readTLS(session, bytes)
			bytes = peer.get_available_bytes()
	
	udp.poll()
	while udp.is_connection_available():
		var peer : PacketPeerUDP = udp.take_connection()
		var packet : PackedByteArray = peer.get_packet()
		for session in waiting_for_authorization:
			if session.host == peer.get_packet_ip() and session.port == peer.get_packet_port():
				session.udp = peer
				waiting_for_authorization.erase(session)
				if session.hmac_authorisation == packet:
					session.tls.put_u8(Utils.MessageType.RESPONSE_OK)
				else:
					session.tls.put_u8(Utils.MessageType.ERROR_CANNOT_AUTHORISE_UDP)
					authorisation_failed.append(session)
	
	for session in authorisation_failed:
		if session.udp.get_available_packet_count() > 0:
			var packet : PackedByteArray = session.udp.get_packet()
			if session.hmac_authorisation == packet:
				session.tls.put_u8(Utils.MessageType.RESPONSE_OK)
				authorisation_failed.erase(session)
			else:
				session.tls.put_u8(Utils.MessageType.ERROR_CANNOT_AUTHORISE_UDP)

signal signed_up(result : Utils.MessageType)
func readTLS(session : Account, bytes : int) -> Error:
	var peer := session.tls
	var msgType : int = peer.get_u8()
	match msgType:
		Utils.MessageType.TEST_BYTE_BY_BYTE:
			print("test")
			print(peer.get_string(0))
		
		Utils.MessageType.SIGN_UP:
			if bytes < 3:
				if bytes > 1: peer.get_partial_data(bytes - 1)
				peer.put_u8(Utils.MessageType.ERROR_TO_FEW_BYTES)
				return ERR_INVALID_DATA
			var login_len : int = peer.get_u8()
			var pass_len : int = peer.get_u8()
			if bytes < 3 + login_len + pass_len + Utils.salt_len:
				if bytes > 3: peer.get_partial_data(bytes - 3)
				peer.put_u8(Utils.MessageType.ERROR_TO_FEW_BYTES)
				return ERR_INVALID_DATA
			peer.put_u8(create_account(peer.get_string(login_len), peer.get_string(pass_len), peer.get_string(Utils.salt_len)))
		
		Utils.MessageType.ASK_FOR_SALT:
			if bytes < 2:
				peer.put_u8(Utils.MessageType.ERROR_TO_FEW_BYTES)
				return ERR_INVALID_DATA
			var login_len : int = peer.get_u8()
			if bytes < 2 + login_len:
				if bytes > 2: peer.get_partial_data(bytes - 2)
				peer.put_u8(Utils.MessageType.ERROR_TO_FEW_BYTES)
				return ERR_INVALID_DATA
			var login = peer.get_string(login_len)
			var err_info = get_account_info(login)
			peer.put_u8(err_info[0])
			if err_info[0] != Utils.MessageType.RESPONSE_OK:
				return ERR_INVALID_DATA
			session.login = login
			var packet : PackedByteArray = [Utils.MessageType.SALT]
			packet.append_array(err_info[3].to_ascii_buffer())
			peer.put_data(packet)
			session.id = err_info[1]
			session.password = err_info[2]
		
		Utils.MessageType.HASHED_PASSWORD:
			if bytes < 2:
				peer.put_u8(Utils.MessageType.ERROR_TO_FEW_BYTES)
				return ERR_INVALID_DATA
			var pass_len : int = peer.get_u8()
			if bytes < 2 + pass_len:
				if bytes > 2: peer.get_partial_data(bytes - 2)
				peer.put_u8(Utils.MessageType.ERROR_TO_FEW_BYTES)
				return ERR_INVALID_DATA
			var password = peer.get_string(pass_len)
			if session.password != password:
				print("Invalid password")
				peer.put_u8(Utils.MessageType.ERROR_INVALID_HASHED_PASSWORD)
				return ERR_INVALID_DATA
			print("Successfully logged in")
			peer.put_u8(Utils.MessageType.RESPONSE_OK)
		
		Utils.MessageType.JUST_STRING:
			var msg : String = peer.get_string()
			print("tls: ", msg)
			peer.put_u8(Utils.MessageType.JUST_STRING)
			peer.put_string("Received message: \"" + msg + "\"")
		
		Utils.MessageType.ERROR_UNEXISTING_MESSAGE_TYPE:
			print("Client send back error UNEXISTING_MESSAGE_TYPE")
		
		Utils.MessageType.ERROR_TO_FEW_BYTES:
			print("Client send back error TO_FEW_BYTES")
		
		_:
			peer.put_u8(Utils.MessageType.ERROR_UNEXISTING_MESSAGE_TYPE)
			if bytes > 1: peer.get_partial_data(bytes - 1)
			print("MessageType not exists")
			return ERR_BUG
	
	return OK

func create_account(login : String, password : String, salt : String) -> Utils.MessageType:
	var p : float = randf()
	if p <= 0.2:
		print("Creating account: login: ", login, ", password: ", password, ", salt: ", salt)
		return Utils.MessageType.RESPONSE_OK
	elif p <= 0.4:
		print("Login already in database")
		return Utils.MessageType.ERROR_LOGIN_ALREADY_IN_DATABASE
	elif p <= 0.6:
		print("Invalid login")
		return Utils.MessageType.ERROR_INVALID_LOGIN
	elif p <= 0.8:
		print("Invalid hashed password")
		return Utils.MessageType.ERROR_INVALID_HASHED_PASSWORD
	else:
		print("Invalid salt")
		return Utils.MessageType.ERROR_INVALID_SALT

func get_account_info(login : String) -> Array:
	var p : float = randf()
	if p <= 0.4:
		return [Utils.MessageType.RESPONSE_OK, 1, "password", "placeholder"]
		#[OK, id, hashed_password, salt]
	elif p <= 0.7:
		print("Login not in database")
		return [Utils.MessageType.ERROR_LOGIN_NOT_IN_DATABASE]
	else:
		print("Invalid login")
		return [Utils.MessageType.ERROR_INVALID_LOGIN]
