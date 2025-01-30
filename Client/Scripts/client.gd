extends Node

func _ready() -> void:
	set_waiting_timer.call_deferred()
	packets_to_resend.resize(32)
	randomize()

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
			print("MessageType not exists: ", msgType)
			return ERR_BUG
	
	return OK

signal set_resources(val : int)
signal change_position(player : int, id : int, position : Vector2)
signal change_health(player : int, id : int, health : int)
signal summon_build(player : int, id : int, type : Utils.EntityType, position : Vector2, health : int)
signal appear(id : int, type : Utils.EntityType, position : Vector2, health : int)
signal die_destroy(player : int, id : int)
signal disappear(id : int)
signal upgraded(upgrade_type : Utils.MessageType, character_type : Utils.EntityType, level : int)
# w razie problemów spróbować wyrzucać wszystkie pakiety prócz ostatniego
# w razie przeskoków spróbować dodać id pakietom od serwera i ignorować docierające w złej kolejności
func readUDP() -> Error:
	var packet := udp.get_packet()
	# można dodać sprawdzanie, gdzie dokładnie się różni, żeby wiedzieć, które ruchy zostały obsłużone
	# w ten sposób, można zauważyć niepowodzenie w jakiejś akcji i to sygnalizować (choć nie będzie to takie proste)
	server_received = packet.slice(0, 32)
	
	set_resources.emit(packet.decode_u16(32))
	
	var i : int = 34
	var packet_size : int = packet.size()
	if i < packet_size:
		print("Interesting packet")
	while i < packet_size:
		match packet[i]: # use changes.gd
			Utils.MessageType.SUMMONED_BUILT:
				if i + 7 >= packet_size:
					print("Too few bytes for summoned_built")
					return ERR_INVALID_DATA
				var x = 0.25 * packet.decode_s16(i + 3)
				var y = 0.25 * packet.decode_s16(i + 5)
				summon_build.emit(0, packet[i+1], packet[i+2], Vector2(x, y), packet[i+5])
				i += 8
			Utils.MessageType.SUMMONED_BUILT_OPP:
				if i + 7 >= packet_size:
					print("Too few bytes for summoned_built_opp")
					return ERR_INVALID_DATA
				var x = 0.25 * packet.decode_s16(i + 3)
				var y = 0.25 * packet.decode_s16(i + 5)
				summon_build.emit(1, packet[i+1], packet[i+2], Vector2(x, y), packet[i+5])
				i += 8
			Utils.MessageType.APPEARED:
				if i + 7 >= packet_size:
					print("Too few bytes for appeared")
					return ERR_INVALID_DATA
				var x = 0.25 * packet.decode_s16(i + 3)
				var y = 0.25 * packet.decode_s16(i + 5)
				appear.emit(packet[i+1], packet[i+2], Vector2(x, y), packet[i+5])
				i += 8
			Utils.MessageType.DIED_DESTROYED:
				if i + 1 >= packet_size:
					print("Too few bytes for died_destroyed")
					return ERR_INVALID_DATA
				die_destroy.emit(0, packet[i+1])
				i += 2
			Utils.MessageType.DIED_DESTROYED_OPP:
				if i + 1 >= packet_size:
					print("Too few bytes for died_destroyed")
					return ERR_INVALID_DATA
				die_destroy.emit(1, packet[i+1])
				i += 2
			Utils.MessageType.DISAPPEARED:
				if i + 1 >= packet_size:
					print("Too few bytes for disappeared")
					return ERR_INVALID_DATA
				die_destroy.emit(packet[i+1])
				i += 2
			Utils.MessageType.UPGRADED_SPEED,\
			Utils.MessageType.UPGRADED_HEALTH,\
			Utils.MessageType.UPGRADED_DAMAGE:
				if i + 2 >= packet_size:
					print("Too few bytes for disappeared")
					return ERR_INVALID_DATA
				upgraded.emit(packet[i], packet[i+1], packet[i+2])
				i += 3
			Utils.MessageType.POS_CHANGE:
				i += 1
				if i >= packet_size:
					print("Too few bytes for pos_change")
					return ERR_INVALID_DATA
				var last = i + 5 * packet[i]
				if last >= packet_size:
					print("Too few bytes for pos_change")
					return ERR_INVALID_DATA
				i += 1
				while i <= last:
					var x = 0.25 * packet.decode_s16(i+1)
					var y = 0.25 * packet.decode_s16(i+3)
					change_position.emit(0, packet[i], Vector2(x, y))
					i += 5
			Utils.MessageType.POS_CHANGE_OPP:
				i += 1
				if i >= packet_size:
					print("Too few bytes for pos_change")
					return ERR_INVALID_DATA
				var last = i + 5 * packet[i]
				if last >= packet_size:
					print("Too few bytes for pos_change")
					return ERR_INVALID_DATA
				i += 1
				while i <= last:
					var x = 0.25 * packet.decode_s16(i+1)
					var y = 0.25 * packet.decode_s16(i+3)
					change_position.emit(1, packet[i], Vector2(x, y))
					i += 5
			Utils.MessageType.HP_CHANGE:
				i += 1
				if i >= packet_size:
					print("Too few bytes for pos_change")
					return ERR_INVALID_DATA
				var last = i + 2 * packet[i]
				if last >= packet_size:
					print("Too few bytes for pos_change")
					return ERR_INVALID_DATA
				i += 1
				while i <= last:
					print("hp change, id: ", packet[i])
					change_health.emit(0, packet[i], packet[i+1])
					i += 2
			Utils.MessageType.HP_CHANGE_OPP:
				i += 1
				if i >= packet_size:
					print("Too few bytes for pos_change")
					return ERR_INVALID_DATA
				var last = i + 2 * packet[i]
				if last >= packet_size:
					print("Too few bytes for pos_change")
					return ERR_INVALID_DATA
				i += 1
				while i <= last:
					print("hp change opp, id: ", packet[i])
					change_health.emit(1, packet[i], packet[i+1])
					i += 2
			Utils.MessageType.POS_HP_CHANGE:
				i += 1
				if i >= packet_size:
					print("Too few bytes for pos_change")
					return ERR_INVALID_DATA
				var last = i + 6 * packet[i]
				if last >= packet_size:
					print("Too few bytes for pos_change")
					return ERR_INVALID_DATA
				i += 1
				while i <= last:
					var x = 0.25 * packet.decode_s16(i+1)
					var y = 0.25 * packet.decode_s16(i+3)
					change_position.emit(0, packet[i], Vector2(x, y))
					change_health.emit(0, packet[i], packet[i+5])
					i += 6
			Utils.MessageType.POS_HP_CHANGE_OPP:
				i += 1
				if i >= packet_size:
					print("Too few bytes for pos_change")
					return ERR_INVALID_DATA
				var last = i + 6 * packet[i]
				if last >= packet_size:
					print("Too few bytes for pos_change")
					return ERR_INVALID_DATA
				i += 1
				while i <= last:
					var x = 0.25 * packet.decode_s16(i+1)
					var y = 0.25 * packet.decode_s16(i+3)
					change_position.emit(1, packet[i], Vector2(x, y))
					change_health.emit(1, packet[i], packet[i+5])
					i += 6
	
	return OK

var next_packet_id : int = 1
var new_packet : PackedByteArray
var is_new_packet := false
var packets_to_resend : Array[PackedByteArray]
var no_repackets : int = 0
var server_received : PackedByteArray
func writeUDP() -> void:
	var i := 0
	while i < no_repackets:
		if packets_to_resend[i][32] in server_received:
			print("Packet end: ", packets_to_resend[i][32])
			no_repackets -= 1
			packets_to_resend[i] = packets_to_resend[no_repackets]
		else:
			udp.put_packet(packets_to_resend[i])
			print("Sent packet of id: ", packets_to_resend[i][32])
			i += 1
	if is_new_packet:
		udp.put_packet(new_packet)
		is_new_packet = false
		packets_to_resend[no_repackets] = new_packet
		no_repackets += 1

func send_udp_packet(packet : PackedByteArray) -> void:
	var hmac := token.duplicate()
	hmac.append_array(packet)
	hmac = Utils.crypto.hmac_digest(Utils.hash_type, key, hmac)
	hmac.append(next_packet_id)
	next_packet_id = (next_packet_id + 1) % 256
	hmac.append_array(packet)
	new_packet = hmac
	is_new_packet = true

func build(building_type : Utils.EntityType, position : Vector2) -> void:
	var packet : PackedByteArray
	packet.resize(6)
	packet.encode_u8(0, Utils.MessageType.BUILD)
	packet.encode_u8(1, building_type)
	packet.encode_s16(2, roundi(position.x * 4))
	packet.encode_s16(4, roundi(position.y * 4))
	send_udp_packet(packet)

func summon(character_type : Utils.EntityType, position : Vector2) -> void:
	var packet : PackedByteArray
	packet.resize(6)
	packet.encode_u8(0, Utils.MessageType.SUMMON)
	packet.encode_u8(1, character_type)
	packet.encode_s16(2, roundi(position.x * 4))
	packet.encode_s16(4, roundi(position.y * 4))
	send_udp_packet(packet)

func move(characters : PackedByteArray, position : Vector2) -> void:
	var packet : PackedByteArray
	packet.resize(5)
	packet.encode_u8(0, Utils.MessageType.MOVE)
	packet.encode_s16(1, roundi(position.x * 4))
	packet.encode_s16(3, roundi(position.y * 4))
	packet.append_array(characters)
	send_udp_packet(packet)

func attack(characters : PackedByteArray, target : int) -> void:
	var packet : PackedByteArray
	packet.resize(2)
	packet.encode_u8(0, Utils.MessageType.ATTACK)
	packet.encode_u8(1, target)
	packet.append_array(characters)
	send_udp_packet(packet)

# alternatywne wersje move oraz attack, które mogą zwiększyć optymalizację
#func move(characters : PackedByteArray, no_characters : int, position : Vector2) -> void:
	#characters.encode_s16(no_characters + 1, roundi(position.x * 4))
	#characters.encode_s16(no_characters + 3, roundi(position.y * 4))
	#send_udp_packet(characters.slice(0, no_characters + 5))

#func attack(characters : PackedByteArray, no_characters : int, target : int) -> void:
	#characters.encode_u8(no_characters + 1, target)
	#send_udp_packet(characters.slice(0, no_characters + 2))

func upgrade(upgrade_type : Utils.MessageType, entity_type : Utils.EntityType) -> void:
	var packet : PackedByteArray
	packet.resize(2)
	packet.encode_u8(0, upgrade_type)
	packet.encode_u8(1, entity_type)
	send_udp_packet(packet)

#Waiting for responses
var timer : Timer
func set_waiting_timer() -> void:
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
var waiting_for_salt := false
func sign_in(login : String, password : String) -> Utils.MessageType:
	var packet : PackedByteArray
	var login_len : int = login.length()
	packet.resize(2 + login_len)
	packet.encode_u8(0, Utils.MessageType.ASK_FOR_SALT)
	packet.encode_u8(1, login_len)
	encode_string(packet, 2, login)
	tls.put_data(packet)
	var response := await wait_for_response()
	if response != Utils.MessageType.RESPONSE_OK:
		return response
	waiting_for_salt = true
	var salt : String = await continue_signing
	waiting_for_salt = false
	var hashed_password := password
	var hash_len := hashed_password.length()
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
		print("Server cannot prepare game: ", response)
		return response
	if await waiting_for_opponent:
		tls.put_u8(Utils.MessageType.GAME_CANCELED)
		print("Game canceled")
		return Utils.MessageType.GAME_CANCELED
	
	in_game = true
	print("Game started")
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
	
	var response := tcp.get_u8() as Utils.MessageType
	if response == Utils.MessageType.NO_MORE_FREE_SEATS:
		print("No more free seats")
		tcp.disconnect_from_host()
		return ERR_OUT_OF_MEMORY
	if response != Utils.MessageType.RESPONSE_OK:
		print("Error: ", response)
		tcp.disconnect_from_host()
		return ERR_CONNECTION_ERROR
	
	tls = StreamPeerTLS.new()
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
