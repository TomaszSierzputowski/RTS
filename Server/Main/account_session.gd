extends RefCounted
class_name Account

var tls : StreamPeerTLS = null
var udp : PacketPeerUDP = null

var host : String
var tcp_port : int
var udp_port : int

var id : int
var login : String
var password : String
var token : PackedByteArray
var key : PackedByteArray
var hmac_authorisation : PackedByteArray

func _init(peer : StreamPeerTLS) -> void:
	tls = peer
	var tcp := tls.get_stream() as StreamPeerTCP
	host = tcp.get_connected_host()
	tcp_port = tcp.get_connected_port()
	token = Utils.crypto.generate_random_bytes(Utils.token_len)
	key = Utils.crypto.generate_random_bytes(Utils.key_len)
	hmac_authorisation = Utils.crypto.hmac_digest(Utils.hash_type, key, token)

func hmac(packet : PackedByteArray) -> PackedByteArray:
	var res := token.duplicate()
	res.append_array(packet)
	return Utils.crypto.hmac_digest(Utils.hash_type, key, res)
