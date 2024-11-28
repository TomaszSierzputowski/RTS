extends Node
class_name GameRoom

var players : Array[Account]

func _init(player1 : Account, player2 : Account) -> void:
	received_ids.resize(max_last_ids)
	players.resize(2)
	players[0] = player1
	players[1] = player2
	process_thread_group = PROCESS_THREAD_GROUP_SUB_THREAD

func _ready() -> void:
	print("Game started")
	print("PLayer 1: ", players[0].id)
	print("Player 2: ", players[1].id)

func _process(_delta : float) -> void:
	while players[0].udp.get_available_packet_count() > 0:
		readUDP(0)
	
	while players[1].udp.get_available_packet_count() > 0:
		readUDP(1)

const max_last_ids : int = 32
var received_ids : PackedByteArray
var id_idx : int = 0
func readUDP(player : int) -> Utils.MessageType:
	var peer := players[player].udp
	var packet := peer.get_packet()
	var id := packet.decode_u8(32)
	if id in received_ids:
		return Utils.MessageType.RESPONSE_OK
	var hmac := packet.slice(0, Utils.hmac_len)
	packet = packet.slice(Utils.hmac_len + 1)
	if hmac != players[player].hmac(packet):
		#peer.put_packet([Utils.MessageType.ERROR_INVALID_HMAC_ERROR] as PackedByteArray)
		print("Invalid hmac for packet of id:", id, " from player of id: ", players[player].id)
		return Utils.MessageType.ERROR_INVALID_HMAC_ERROR
	received_ids.encode_u8(id_idx, id)
	id_idx = (id_idx + 1) % max_last_ids
	var packet_size = packet.size()
	var msgType := packet.decode_u8(0) as Utils.MessageType
	match msgType:
		Utils.MessageType.BUILD:
			if packet_size < 6:
				print("To few bytes for build packet of id:", id, " from player of id: ", players[player].id)
				return Utils.MessageType.ERROR_TO_FEW_BYTES
			var building_type := packet.decode_u8(1)
			var position := Vector2(0.25 * packet.decode_s16(2), 0.25 * packet.decode_s16(4))
			if not build(player, building_type, position):
				return Utils.MessageType.ERROR_CANNOT_BUILD
		
		Utils.MessageType.SUMMON:
			if packet_size < 6:
				print("To few bytes for summon packet of id:", id, " from player of id: ", players[player].id)
				return Utils.MessageType.ERROR_TO_FEW_BYTES
			var character_type := packet.decode_u8(1)
			var position := Vector2(0.25 * packet.decode_s16(2), 0.25 * packet.decode_s16(4))
			if not summon(player, character_type, position):
				return Utils.MessageType.ERROR_CANNOT_SUMMON
		
		Utils.MessageType.MOVE:
			if packet_size < 6:
				print("To few bytes for move packet of id:", id, " from player of id: ", players[player].id)
				return Utils.MessageType.ERROR_TO_FEW_BYTES
			var position := Vector2(0.25 * packet.decode_s16(1), 0.25 * packet.decode_s16(3))
			var ids := packet.slice(5)
			if not move(player, ids, position):
				return Utils.MessageType.ERROR_CANNOT_MOVE
		
		Utils.MessageType.ATTACK:
			if packet_size < 3:
				print("To few bytes for attack packet of id:", id, " from player of id: ", players[player].id)
				return Utils.MessageType.ERROR_TO_FEW_BYTES
			var target := packet.decode_u8(1)
			var ids := packet.slice(2)
			if not attack(player, ids, target):
				return Utils.MessageType.ERROR_CANNOT_ATTACK
		
		_:
			pass
	
	return Utils.MessageType.RESPONSE_OK



# tmp - dodać funkcjom działanie
func build(_player : int, _building_type : int, _position : Vector2) -> bool:
	return true

func summon(_player : int, _character_type : int, _position : Vector2) -> bool:
	return true

func move(_player : int, _ids : PackedByteArray, _position : Vector2) -> bool:
	return true

func attack(_player : int, _ids : PackedByteArray, _target : int) -> bool:
	return true
