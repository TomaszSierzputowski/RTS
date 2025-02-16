extends Node
class_name GameRoom

var players : Array[Account]

var session : GameSession

func _init(player1 : Account, player2 : Account) -> void:
	received_ids.resize(2)
	received_ids[0].resize(max_last_ids)
	received_ids[1].resize(max_last_ids)
	players.resize(2)
	players[0] = player1
	players[1] = player2
	changes.resize(2)
	changes[0] = Changes.new(0)
	changes[1] = Changes.new(1)
	#process_thread_group = PROCESS_THREAD_GROUP_SUB_THREAD
	
	session = GameSession.new()
	
	session.game_summoned_built[0].connect(changes[0].summoned_built)
	session.game_summoned_built[1].connect(changes[1].summoned_built)
	session.game_died_destroyed[0].connect(changes[0].died_destroyed)
	session.game_died_destroyed[1].connect(changes[1].died_destroyed)
	session.game_appeared[0].connect(changes[0].appeared)
	session.game_appeared[1].connect(changes[1].appeared)
	session.game_disappeared[0].connect(changes[0].disappeared)
	session.game_disappeared[1].connect(changes[1].disappeared)
	session.game_position_changed[0].connect(changes[0].position_changed)
	session.game_position_changed[1].connect(changes[1].position_changed)
	session.game_hp_changed[0].connect(changes[0].hp_changed)
	session.game_hp_changed[1].connect(changes[1].hp_changed)

func _ready() -> void:
	#print("Game started")
	#print("PLayer 1: ", players[0].id)
	#print("Player 2: ", players[1].id)
	add_child(session)

func _process(_delta : float) -> void:
	while players[0].udp.get_available_packet_count() > 0:
		readUDP(0)
	
	while players[1].udp.get_available_packet_count() > 0:
		readUDP(1)
	
	send_board_changes(0)
	send_board_changes(1)

const max_last_ids : int = 32
var received_ids : Array[PackedByteArray]
var id_idx : Array[int] = [0, 0]
# w razie problemów spróbować wyrzucać wszystkie pakiety prócz ostatniego
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
	#print("Packet ", id, ":")
	var packet_size = packet.size()
	var msgType := packet.decode_u8(0) as Utils.MessageType
	match msgType:
		Utils.MessageType.BUILD:
			if packet_size < 6:
				print("To few bytes for build packet of id:", id, " from player of id: ", players[player].id)
				return Utils.MessageType.ERROR_TO_FEW_BYTES
			var building_type := packet.decode_u8(1) as Utils.EntityType
			var position := Vector2(0.25 * packet.decode_s16(2), 0.25 * packet.decode_s16(4))
			session.summon(player, building_type, position)
		
		Utils.MessageType.SUMMON:
			if packet_size < 6:
				print("To few bytes for summon packet of id:", id, " from player of id: ", players[player].id)
				return Utils.MessageType.ERROR_TO_FEW_BYTES
			var character_type := packet.decode_u8(1) as Utils.EntityType
			var position := Vector2(0.25 * packet.decode_s16(2), 0.25 * packet.decode_s16(4))
			#game_summon(player, character_type, position)
			session.summon(player, character_type, position)
		
		Utils.MessageType.MOVE:
			if packet_size < 6:
				print("To few bytes for move packet of id:", id, " from player of id: ", players[player].id)
				return Utils.MessageType.ERROR_TO_FEW_BYTES
			var position := Vector2(0.25 * packet.decode_s16(1), 0.25 * packet.decode_s16(3))
			var ids := packet.slice(5)
			#game_move(player, ids, position)
			session.move(player, ids, position)
		
		Utils.MessageType.ATTACK:
			if packet_size < 3:
				print("To few bytes for attack packet of id:", id, " from player of id: ", players[player].id)
				return Utils.MessageType.ERROR_TO_FEW_BYTES
			var target := packet.decode_u8(1)
			var ids := packet.slice(2)
			game_attack(player, ids, target)
		
		_:
			print("Unknown message type")
			pass
	
	return Utils.MessageType.RESPONSE_OK


var changes : Array[Changes]
func send_board_changes(player : int) -> void:
	var packet := changes[player].extract_changes()
	if packet[0] == Utils.MessageType.END_GAME and packet.size() == 34:
		queue_free()
	for i in range(32):
		packet[i] = received_ids[player][i]
	packet.encode_u16(32, session.get_resource(player))
	players[player].udp.put_packet(packet)

func game_attack(player : int, ids : PackedByteArray, target : int) -> void:
	print("Player ", player, " attacked with ", ids, " opponent's ", target)
