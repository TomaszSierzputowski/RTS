extends Node

@onready var server_ip = $ConnectButton/ServerIpInput
@onready var port = $ConnectButton/PortInput

var tcp : StreamPeerTCP = StreamPeerTCP.new()
var udp : PacketPeerUDP = PacketPeerUDP.new()

var status : StreamPeerTCP.Status = StreamPeerTCP.STATUS_NONE

func _on_connect_button_pressed() -> void:
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
