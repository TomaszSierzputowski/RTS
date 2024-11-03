extends Node

var udp : UDPServer = UDPServer.new()
var udps : Array[PacketPeerUDP]

var tcp : TCPServer = TCPServer.new()
var tcps : Array[StreamPeerTLS]
#var cfg : TLSOptions

func _ready() -> void:
	udp.listen(8080)
	tcp.listen(8080)
	#var key : CryptoKey = load("res://Server/key.key")
	#var cert : X509Certificate = load("res://Shared/cert.crt")
	#cfg = TLSOptions.server(key, cert)
	#dtls.setup(cfg)
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
		print("tls peer connected")
		
	for peer in tcps:
		peer.poll()
		var status : StreamPeerTLS.Status = peer.get_status()
		if status == StreamPeerTLS.Status.STATUS_HANDSHAKING:
			continue
		if status == StreamPeerTLS.STATUS_DISCONNECTED or status == StreamPeerTLS.STATUS_ERROR:
			tcps.erase(peer)
			continue
		while peer.get_available_bytes() > 0:
			print("tcp: ", peer.get_string(), ", ")

func tmp():
	#for peer in tcps:
	for peer in []:
		peer.poll()
		var status : StreamPeerTCP.Status = peer.get_status()
		if status == StreamPeerTCP.STATUS_CONNECTING:
			continue
		if status == StreamPeerTCP.STATUS_NONE or status == StreamPeerTCP.STATUS_ERROR:
			tcps.erase(peer)
			continue
		while peer.get_available_bytes() > 0:
			print("tcp: ", peer.get_string(), ", ", peer.get_connected_host())
	
	udp.poll()
	while udp.is_connection_available():
		var peer: PacketPeerUDP = udp.take_connection()
		udps.append(peer)
		print("udp peer connected")
	
	for peer in udps:
		while peer.get_available_packet_count() > 0:
			print("udp: ", peer.get_packet().get_string_from_ascii(), ", ", peer.get_packet_ip())
