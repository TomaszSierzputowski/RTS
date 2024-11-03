extends Node

var udp : UDPServer = UDPServer.new()
var udps : Array[PacketPeerUDP]

var tcp : TCPServer = TCPServer.new()
var tcps : Array[StreamPeerTCP]
#var cfg : TLSOptions

func _ready() -> void:
	udp.listen(8080)
	tcp.listen(8080, "172.18.219.106")
	#var key : CryptoKey = load("res://Server/key.key")
	#var cert : X509Certificate = load("res://Shared/cert.crt")
	#cfg = TLSOptions.server(key, cert)
	#dtls.setup(cfg)
	print("server is listening on port 8080")

func _process(_delta : float) -> void:
	while tcp.is_connection_available():
		var peer : StreamPeerTCP = tcp.take_connection()
		tcps.append(peer)
		print("tcp peer connected")
	
	for peer in tcps:
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
