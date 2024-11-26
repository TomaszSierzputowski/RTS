extends Node
class_name GameRoom

var player1 : Account
var player2 : Account

func _ready() -> void:
	received_ids.resize(max_last_ids)

func _process(delta : float) -> void:
	while player1.udp.get_available_packet_count() > 0:
		readUDP(player1)
	
	while player2.udp.get_available_packet_count() > 0:
		readUDP(player2)

const max_last_ids : int = 32
var received_ids : PackedByteArray
var id_idx : int = 0
func readUDP(player : Account) -> Utils.MessageType:
	var peer := player.udp
	var packet := peer.get_packet()
	var id := packet.decode_u8(0)
	if id in received_ids:
		return Utils.MessageType.RESPONSE_OK
	var hmac := packet.slice(1, 1 + Utils.hmac_len)
	packet = packet.slice(1 + Utils.hmac_len)
	if hmac != player.hmac(packet):
		peer.put_packet([Utils.MessageType.ERROR_INVALID_HMAC_ERROR] as PackedByteArray)
		return Utils.MessageType.ERROR_INVALID_HMAC_ERROR
	received_ids.encode_u8(id_idx, id)
	id_idx = (id_idx + 1) % max_last_ids
	var msgType := packet.decode_u8(0) as Utils.MessageType
	match msgType:
		Utils.MessageType.BUILD:
			pass
		
		Utils.MessageType.SUMMON:
			pass
		
		Utils.MessageType.MOVE:
			pass
		
		Utils.MessageType.ATTACK:
			pass
		
		_:
			pass
	
	return Utils.MessageType.RESPONSE_OK
