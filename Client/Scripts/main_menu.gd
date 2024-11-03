extends Node

@onready var server_ip = $ConnectButton/ServerIpInput
@onready var port = $ConnectButton/PortInput

var tcp : StreamPeerTCP = StreamPeerTCP.new()
var udp : PacketPeerUDP = PacketPeerUDP.new()

var status : StreamPeerTCP.Status = StreamPeerTCP.STATUS_NONE

func _on_connect_button_pressed() -> void:
	open_tls()

func open():
	if status == StreamPeerTCP.STATUS_NONE:
		print("trying to connect...")
		tcp.connect_to_host(server_ip.text, port.text.to_int())
		udp.connect_to_host(server_ip.text, port.text.to_int())
		status = StreamPeerTCP.STATUS_CONNECTING
	elif status == StreamPeerTCP.STATUS_CONNECTED:
		tcp.put_string("Hello server, it's me client")
		udp.put_packet("Hello server, it's me client".to_ascii_buffer())
	elif status == StreamPeerTCP.STATUS_CONNECTING:
		print("trying to finalize connection")
		tcp.poll()
		status = tcp.get_status()
	else:
		print("ERROR")

var tls : StreamPeerTLS

func open_tls() -> Error:
	tls = StreamPeerTLS.new()
	#_connection.big_endian = true
	tcp = StreamPeerTCP.new()
	#tcp.big_endian = true
	var tcp_connect_err := tcp.connect_to_host(server_ip.text, port.text.to_int())
	if tcp_connect_err != OK:
		print("Failed to connect")
		return tcp_connect_err
	
	while tcp.get_status() == StreamPeerTCP.Status.STATUS_CONNECTING:
		OS.delay_msec(1)
		var poll_err := tcp.poll()
		if poll_err != OK:
			print("Failed to poll")
			return poll_err
	if tcp.get_status() != StreamPeerTCP.Status.STATUS_CONNECTED:
		print("TCP Connection error status: ", tcp.get_status())
		return ERR_CONNECTION_ERROR
	
	print("Connected tcp")
	
	var tls_connect_err : Error = tls.connect_to_stream(tcp, "LAPTOP-P6J7HDUS", TLSOptions.client_unsafe(load("res://Shared/cert.crt")))
	if tls_connect_err != OK:
		print("Failed to tls connect")
		return tls_connect_err
	while tls.get_status() == StreamPeerTLS.Status.STATUS_HANDSHAKING:
		print("still handshaking")
		OS.delay_msec(1)
		tls.poll()
	if tls.get_status() != StreamPeerTLS.Status.STATUS_CONNECTED:
		print("TLS Connection error status: ", tls.get_status())
		return ERR_CONNECTION_ERROR
	
	print("Connected tls")
	
	OS.delay_msec(3000)
	
	tls.poll()
	tls.put_string("Hello server, it's me client\nAnd know I am sending via TLS!!!")
	tls.poll()
	
	return OK
