extends Node

@onready var tls_host_input = $UI/V/Custom/TLS/Host
@onready var tls_port_input = $UI/V/Custom/TLS/Port
@onready var udp_host_input = $UI/V/Custom/UDP/Host
@onready var udp_port_input = $UI/V/Custom/UDP/Port
@onready var input = $UI/V/Custom

func _ready() -> void:
	pass

var mode : int
func _on_connect_button_pressed() -> void:
	match mode:
		0:
			Client.connect_to_server("127.0.0.1", 8080, "127.0.0.1", 8080)
		1:
			Client.connect_to_server("aytumn.loclato.net", 7628, "aytumn.localto.net", 7628)
		2:
			Client.connect_to_server(tls_host_input.text, tls_port_input.text.to_int(), udp_host_input.text, udp_port_input.text.to_int())

func _on_mode_selected(_mode : int):
	mode = _mode
	if mode == 2:
		input.visible = true
	else:
		input.visible = false
