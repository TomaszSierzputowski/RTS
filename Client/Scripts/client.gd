extends Node

func _ready() -> void:
	set_waiting_timer.call_deferred()
	packets_to_send.resize(32)

#Reading from server
func _process(_delta: float) -> void:
	if not connected:
		return
	tls.poll()
	var status : StreamPeerTLS.Status = tls.get_status()
	match status:
		StreamPeerTLS.Status.STATUS_DISCONNECTED,\
		StreamPeerTLS.Status.STATUS_ERROR,\
		StreamPeerTLS.Status.STATUS_ERROR_HOSTNAME_MISMATCH:
			connected = false
			return
		StreamPeerTLS.Status.STATUS_HANDSHAKING:
			return
	var bytes : int = tls.get_available_bytes()
	while bytes > 0:
		readTLS(bytes)
		bytes = tls.get_available_bytes()
	if not in_game:
		return
	while udp.get_available_packet_count() > 0:
		readUDP()
	writeUDP()

func readTLS(bytes : int) -> Error:
	var msgType : int = tls.get_u8()
	if waiting_for_response:
		response_received.emit(msgType)
		return OK
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
			if bytes < 1 + Utils.salt_len:
				if bytes > 1: tls.get_partial_data(bytes - 1)
				tls.put_u8(Utils.MessageType.ERROR_TO_FEW_BYTES)
				return ERR_INVALID_DATA
			continue_signing.emit(tls.get_string(Utils.salt_len)) #get_data
		
		Utils.MessageType.TOKEN_AND_KEY:
			if not waiting_for_token_and_key:
				if bytes > 1: tls.get_partial_data(bytes - 1)
				tls.put_u8(Utils.MessageType.ERROR_UNEXPECTED_TOKEN_AND_KEY)
				return ERR_DOES_NOT_EXIST
			if bytes < 1 + Utils.token_len + Utils.key_len:
				if bytes > 1: tls.get_partial_data(bytes - 1)
				tls.put_u8(Utils.MessageType.ERROR_TO_FEW_BYTES)
				return ERR_INVALID_DATA
			token_and_key.emit(tls.get_data(Utils.token_len)[1], tls.get_data(Utils.key_len)[1])
		
		Utils.MessageType.GAME_STARTED:
			waiting_for_opponent.emit(false)
		
		Utils.MessageType.GAME_CANCELED:
			waiting_for_opponent.emit(true)
		
		_:
			tls.put_u8(Utils.MessageType.ERROR_UNEXISTING_MESSAGE_TYPE)
			print("MessageType not exists")
			return ERR_BUG
	
	return OK

func readUDP() -> Error:
	var packet := udp.get_packet()
	var msgType := packet.decode_u8(0) as Utils.MessageType
	match msgType:
		Utils.MessageType.BOARD_STATE:
			pass
		
		Utils.MessageType.ERROR_INVALID_HMAC_ERROR:
			pass
		
		Utils.MessageType.ERROR_CANNOT_BUILD:
			pass
		
		Utils.MessageType.ERROR_CANNOT_SUMMON:
			pass
		
		Utils.MessageType.ERROR_CANNOT_MOVE:
			pass
		
		Utils.MessageType.ERROR_CANNOT_ATTACK:
			pass
		
		_:
			pass
	
	return OK

var next_packet_id : int = 1
var packets_to_send : Array[PackedByteArray]
var no_packets : int = 0
var server_received : PackedByteArray
func writeUDP() -> void:
	var i := 0
	while i < no_packets:
		if packets_to_send[i][0] in server_received:
			no_packets -= 1
			packets_to_send[i] = packets_to_send[no_packets]
		else:
			udp.put_packet(packets_to_send[i])
			i += 1

func send_udp_packet(packet : PackedByteArray) -> void:
	var hmac := token.duplicate()
	hmac.append_array(packet)
	hmac = Utils.crypto.hmac_digest(Utils.hash_type, key, hmac)
	hmac.append(next_packet_id)
	next_packet_id = (next_packet_id + 1) % 256
	hmac.append_array(packet)
	packets_to_send[no_packets] = hmac
	no_packets += 1

func build(building_type : int, position : Vector2) -> void:
	var packet : PackedByteArray
	packet.resize(6)
	packet.encode_u8(0, Utils.MessageType.BUILD)
	packet.encode_u8(1, building_type)
	packet.encode_s16(2, roundi(position.x))
	packet.encode_s16(4, roundi(position.y))
	send_udp_packet(packet)

func summon(character_type : int, position : Vector2) -> void:
	var packet : PackedByteArray
	packet.resize(6)
	packet.encode_u8(0, Utils.MessageType.SUMMON)
	packet.encode_u8(1, character_type)
	packet.encode_s16(2, roundi(position.x))
	packet.encode_s16(4, roundi(position.y))
	send_udp_packet(packet)

func move(characters : PackedByteArray, position : Vector2) -> void:
	var packet : PackedByteArray
	packet.resize(5)
	packet.encode_u8(0, Utils.MessageType.MOVE)
	packet.encode_s16(1, roundi(position.x))
	packet.encode_s16(3, roundi(position.y))
	packet.append_array(characters)
	send_udp_packet(packet)

func attack(characters : PackedByteArray, target : int) -> void:
	var packet : PackedByteArray
	packet.resize(2)
	packet.encode_u8(0, Utils.MessageType.ATTACK)
	packet.encode_u8(1, target)
	packet.append_array(characters)
	send_udp_packet(packet)

#Waiting for responses
var timer : Timer
func set_waiting_timer():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(timeout)
func timeout() -> void:
	response_received.emit(Utils.MessageType.ERROR_TIMEOUT)
var waiting_for_response : bool = false
signal response_received(type : Utils.MessageType)
func wait_for_response() -> Utils.MessageType:
	waiting_for_response = true
	timer.start(1.0)
	var response : Utils.MessageType = await response_received
	timer.stop()
	waiting_for_response = false
	return response

#Testing
func send_test() -> void:
	var packet : PackedByteArray
	packet.resize(1)
	packet.encode_u8(0, Utils.MessageType.TEST_BYTE_BY_BYTE)
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

#Signing up and in
func sign_up(login : String, password : String, salt : String = "placeholder") -> Utils.MessageType:
	var packet : PackedByteArray
	var login_len : int = login.length()
	var pass_len : int = password.length()
	packet.resize(3 + login_len + pass_len + Utils.salt_len)
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
var waiting_for_salt : = false
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

var in_game := false
signal waiting_for_opponent(canceled : bool)
func play() -> Utils.MessageType:
	tls.put_u8(Utils.MessageType.PREPARE_GAME)
	var response = await wait_for_response()
	if response != Utils.MessageType.RESPONSE_OK:
		return response
	if await waiting_for_opponent:
		tls.put_u8(Utils.MessageType.GAME_CANCELED)
		return Utils.MessageType.GAME_CANCELED
	
	in_game = true
	return Utils.MessageType.RESPONSE_OK

func cancel_play() -> void:
	waiting_for_opponent.emit(true)

#Preparing game
signal token_and_key(token : PackedByteArray, key : PackedByteArray)
var waiting_for_token_and_key := false
var token : PackedByteArray
var key : PackedByteArray

#Connecting TCP, TLS and UDP
var tcp : StreamPeerTCP
var tls : StreamPeerTLS
var udp : PacketPeerUDP
var tls_host : String
var tls_port : int
var udp_host : String
var udp_port : int
var connected := false
func connect_to_server(_tls_host : String, _tls_port : int, _udp_host : String, _udp_port : int) -> Error:
	tls_host = _tls_host
	tls_port = _tls_port
	udp_host = _udp_host
	udp_port = _udp_port
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
	var tcp_connect_err := tcp.connect_to_host(tls_host, tls_port)
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
	tcp.put_u8(Utils.MessageType.RESPONSE_OK)
	
	var response := await wait_for_response()
	if response == Utils.MessageType.ERROR_TIMEOUT:
		print("connection timeout")
		tcp.disconnect_from_host()
		return ERR_TIMEOUT
	if response == Utils.MessageType.NO_MORE_FREE_SEATS:
		print("No more free seats")
		tcp.disconnect_from_host()
		return ERR_OUT_OF_MEMORY
	if response != Utils.MessageType.RESPONSE_OK:
		print("Error: ", response)
		tcp.disconnect_from_host()
		return ERR_CONNECTION_ERROR
	
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
	
	connected = true
	
	print("TLS connected")
	
	udp = PacketPeerUDP.new()
	var err = udp.connect_to_host(udp_host, udp_port)
	
	tls.put_u16(udp.get_local_port())
	
	waiting_for_token_and_key = true
	var token_key = await token_and_key
	waiting_for_token_and_key = false
	token = token_key[0]
	key = token_key[1]
	if err != OK:
		return ERR_CONNECTION_ERROR
	response = Utils.MessageType.ERROR_TIMEOUT
	while response == Utils.MessageType.ERROR_TIMEOUT:
		udp.put_packet(Utils.crypto.hmac_digest(Utils.hash_type, key, token))
		response = await wait_for_response()
	if response == Utils.MessageType.ERROR_CANNOT_AUTHORISE_UDP:
		return ERR_UNAUTHORIZED
	
	print("UDP connected")
	
	return OK

func encode_string(packet : PackedByteArray, byte_offset : int, string : String) -> int:
	for c in string.to_ascii_buffer():
		packet.encode_u8(byte_offset, c)
		byte_offset += 1
	return byte_offset
