extends Node
class_name GameRoom

var players : Array[Account]

func _init(player1 : Account, player2 : Account) -> void:
	received_ids.resize(2)
	received_ids[0].resize(max_last_ids)
	received_ids[1].resize(max_last_ids)
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
	
	send_board_state(0)
	send_board_state(1)

const max_last_ids : int = 32
var received_ids : Array[PackedByteArray]
var id_idx : Array[int] = [0, 0]
func readUDP(player : int) -> Utils.MessageType:
	var peer := players[player].udp
	var packet := peer.get_packet()
	var id := packet.decode_u8(32)
	if id in received_ids[player]:
		return Utils.MessageType.RESPONSE_OK
	var hmac := packet.slice(0, Utils.hmac_len)
	packet = packet.slice(Utils.hmac_len + 1)
	if hmac != players[player].hmac(packet):
		#peer.put_packet([Utils.MessageType.ERROR_INVALID_HMAC_ERROR] as PackedByteArray)
		print("Invalid hmac for packet of id:", id, " from player of id: ", players[player].id)
		return Utils.MessageType.ERROR_INVALID_HMAC_ERROR
	received_ids[player].encode_u8(id_idx[player], id)
	id_idx[player] = (id_idx[player] + 1) % max_last_ids
	print("Packet ", id, ":")
	var packet_size = packet.size()
	var msgType := packet.decode_u8(0) as Utils.MessageType
	match msgType:
		Utils.MessageType.BUILD:
			if packet_size < 6:
				print("To few bytes for build packet of id:", id, " from player of id: ", players[player].id)
				return Utils.MessageType.ERROR_TO_FEW_BYTES
			var building_type := packet.decode_u8(1)
			var position := Vector2(0.25 * packet.decode_s16(2), 0.25 * packet.decode_s16(4))
			if not game_build(player, building_type, position):
				return Utils.MessageType.ERROR_CANNOT_BUILD
		
		Utils.MessageType.SUMMON:
			if packet_size < 6:
				print("To few bytes for summon packet of id:", id, " from player of id: ", players[player].id)
				return Utils.MessageType.ERROR_TO_FEW_BYTES
			var character_type := packet.decode_u8(1)
			var position := Vector2(0.25 * packet.decode_s16(2), 0.25 * packet.decode_s16(4))
			if not game_summon(player, character_type, position):
				return Utils.MessageType.ERROR_CANNOT_SUMMON
		
		Utils.MessageType.MOVE:
			if packet_size < 6:
				print("To few bytes for move packet of id:", id, " from player of id: ", players[player].id)
				return Utils.MessageType.ERROR_TO_FEW_BYTES
			var position := Vector2(0.25 * packet.decode_s16(1), 0.25 * packet.decode_s16(3))
			var ids := packet.slice(5)
			if not game_move(player, ids, position):
				return Utils.MessageType.ERROR_CANNOT_MOVE
		
		Utils.MessageType.ATTACK:
			if packet_size < 3:
				print("To few bytes for attack packet of id:", id, " from player of id: ", players[player].id)
				return Utils.MessageType.ERROR_TO_FEW_BYTES
			var target := packet.decode_u8(1)
			var ids := packet.slice(2)
			if not game_attack(player, ids, target):
				return Utils.MessageType.ERROR_CANNOT_ATTACK
		
		_:
			print("Unknown message type")
			pass
	
	return Utils.MessageType.RESPONSE_OK

func send_board_state(player : int) -> void:
	var packet := [Utils.MessageType.BOARD_STATE] as PackedByteArray
	packet.append_array(received_ids[player])
	players[player].udp.put_packet(packet)

# tmp - dodać funkcjom działanie
func game_build(player : int, building_type : int, position : Vector2) -> bool:
	print("Player ", player, " built ", building_type, " on position ", position)
	return true

func game_summon(player : int, character_type : int, position : Vector2) -> bool:
	print("Player ", player, " summoned ", character_type, " on position ", position)
	return true

func game_move(player : int, ids : PackedByteArray, position : Vector2) -> bool:
	print("Player ", player, " moved ", ids, " to position ", position)
	return true

func game_attack(player : int, ids : PackedByteArray, target : int) -> bool:
	print("Player ", player, " attacked with ", ids, " opponent's ", target)
	return true
