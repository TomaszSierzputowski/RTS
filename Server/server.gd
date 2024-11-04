extends Node

var udp : UDPServer = UDPServer.new()
var udps : Array[PacketPeerUDP]

var tcp : TCPServer = TCPServer.new()
var tcps : Array[StreamPeerTLS]

func _ready() -> void:
	udp.listen(8080)
	tcp.listen(8080)
	print("server is listening on port 8080")

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
		while peer.get_available_bytes() > 0:
			readTLS(peer)
	
	udp.poll()
	while udp.is_connection_available():
		var peer: PacketPeerUDP = udp.take_connection()
		udps.append(peer)
		print("UDP connected")
	
	for peer in udps:
		while peer.get_available_packet_count() > 0:
			print("udp: ", peer.get_packet().get_string_from_ascii())

func readTLS(peer : StreamPeerTLS) -> Error:
	var msgType : Utils.MessageType = peer.get_u8()
	match msgType:
		Utils.MessageType.JUST_STRING:
			var msg : String = peer.get_string()
			print("tls: ", msg)
			peer.put_u8(Utils.MessageType.JUST_STRING)
			peer.put_string("Received message: \"" + msg + "\"")
		_:
			peer.put_u8(Utils.MessageType.RESPONSE_ERROR)
			return ERR_BUG
	return OK
	
