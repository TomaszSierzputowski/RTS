extends Node

@onready var tls_host_input = $UI/V/Custom/TLS/Host
@onready var tls_port_input = $UI/V/Custom/TLS/Port
@onready var udp_host_input = $UI/V/Custom/UDP/Host
@onready var udp_port_input = $UI/V/Custom/UDP/Port
@onready var custom_input = $UI/V/Custom
@onready var tunnel_input = $UI/V/Tunnel

func _ready() -> void:
	pass

var mode : int
func _on_connect_button_pressed() -> void:
	if Client.connected:
		Client.play()
	else:
		match mode:
			0:
				await Client.connect_to_server("127.0.0.1", 4443, "127.0.0.1", 4443)
			1:
				await Client.connect_to_server("aptuymn.localto.net", tunnel_input.text.to_int(), "aptuymn.localto.net", tunnel_input.text.to_int())
			2:
				await Client.connect_to_server(tls_host_input.text, tls_port_input.text.to_int(), udp_host_input.text, udp_port_input.text.to_int())

func _on_mode_selected(_mode : int):
	mode = _mode
	match mode:
		0:
			custom_input.visible = false
			tunnel_input.visible = false
		1:
			custom_input.visible = false
			tunnel_input.visible = true
		2:
			custom_input.visible = true
			tunnel_input.visible = false
