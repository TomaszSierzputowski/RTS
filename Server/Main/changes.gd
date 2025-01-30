extends RefCounted
class_name Changes

var main_player : int

class Change:
	var code : PackedByteArray
	var significance : int
	
	func _init(id : int, upgrade : int = -1) -> void:
		if (upgrade == -1):
			code.resize(8)
			code.encode_u8(1, id)
			significance = 0
		else:
			code.resize(3)
			code.encode_u8(0, upgrade)
			code.encode_u8(1, id)
			significance = 0

var quick_access_changes : Array[Change]
var changes : Array[Change]
var no_changes : int = 0

func _init(_main_player : int) -> void:
	main_player = _main_player
	quick_access_changes.resize(521)
	for i in range(256):
		quick_access_changes[i] = Change.new(i)
	for i in range(256):
		quick_access_changes[256 + i] = Change.new(i)
	for i in range(3):
		for j in range(3):
			quick_access_changes[512 + 3 * i + j] = Change.new(i, j)
	changes.resize(521)

func extract_changes() -> PackedByteArray:
	var packet : PackedByteArray
	packet.resize(34)
	var p := [Utils.MessageType.POS_CHANGE, 0] as PackedByteArray
	var no_p := 0
	var po := [Utils.MessageType.POS_CHANGE_OPP, 0] as PackedByteArray
	var no_po := 0
	var h := [Utils.MessageType.HP_CHANGE, 0] as PackedByteArray
	var no_h := 0
	var ho := [Utils.MessageType.HP_CHANGE_OPP, 0] as PackedByteArray
	var no_ho := 0
	var ph := [Utils.MessageType.POS_HP_CHANGE, 0] as PackedByteArray
	var no_ph := 0
	var pho := [Utils.MessageType.POS_HP_CHANGE_OPP, 0] as PackedByteArray
	var no_pho := 0
	var i := 0
	var change : Change
	while i < no_changes:
		change = changes[i]
		match change.code.decode_u8(0):
			Utils.MessageType.POS_CHANGE:
				p.append_array(change.code.slice(1))
				no_p += 1
			Utils.MessageType.POS_CHANGE_OPP:
				po.append_array(change.code.slice(1))
				no_po += 1
			Utils.MessageType.HP_CHANGE:
				h.append_array(change.code.slice(1))
				no_h += 1
			Utils.MessageType.HP_CHANGE_OPP:
				ho.append_array(change.code.slice(1))
				no_ho += 1
			Utils.MessageType.POS_HP_CHANGE:
				ph.append_array(change.code.slice(1))
				no_ph += 1
			Utils.MessageType.POS_HP_CHANGE_OPP:
				pho.append_array(change.code.slice(1))
				no_pho += 1
			_:
				packet.append_array(change.code)
		change.significance -= 1
		if change.significance == 0:
			no_changes -= 1
			changes[i] = changes[no_changes]
		else:
			i += 1
	if no_p > 0:
		p.encode_u8(1, no_p)
		packet.append_array(p)
	if no_po > 0:
		po.encode_u8(1, no_po)
		packet.append_array(po)
	if no_h > 0:
		h.encode_u8(1, no_h)
		packet.append_array(h)
	if no_ho > 0:
		ho.encode_u8(1, no_ho)
		packet.append_array(ho)
	if no_ph > 0:
		ph.encode_u8(1, no_ph)
		packet.append_array(ph)
	if no_pho > 0:
		pho.encode_u8(1, no_pho)
		packet.append_array(pho)
	return packet

func summoned_built(player : int, id : int, entity : Utils.EntityType, position : Vector2):
	var change : Change = quick_access_changes[256 * player + id]
	change.code.resize(8)
	if change.significance > 0:
		print("Unexpected summon of recently changed player's ", player, " entity of id ", id)
	else:
		changes[no_changes] = change
		no_changes += 1
	if player == main_player:
		change.code.encode_u8(0, Utils.MessageType.SUMMONED_BUILT)
	else:
		change.code.encode_u8(0, Utils.MessageType.SUMMONED_BUILT_OPP)
	change.code.encode_u8(2, entity)
	change.code.encode_s16(3, roundi(position.x * 4))
	change.code.encode_s16(5, roundi(position.y * 4))
	change.code.encode_u8(7, 100)
	change.significance = 7

func died_destroyed(player : int, id : int):
	var change : Change = quick_access_changes[256 * player + id]
	change.code.resize(2)
	if change.significance == 0:
		changes[no_changes] = change
		no_changes += 1
	if player == main_player:
		change.code.encode_u8(0, Utils.MessageType.DIED_DESTROYED)
	else:
		change.code.encode_u8(0, Utils.MessageType.DIED_DESTROYED_OPP)
	change.significance = 7

func appeared(id : int, entity : Utils.EntityType, position : Vector2, hp : int):
	var change : Change = quick_access_changes[256 + id]
	change.code.resize(8)
	if change.significance == 0:
		changes[no_changes] = change
		no_changes += 1
	change.code.encode_u8(0, Utils.MessageType.APPEARED)
	change.code.encode_u8(2, entity)
	change.code.encode_s16(3, roundi(position.x * 4))
	change.code.encode_s16(5, roundi(position.y * 4))
	change.code.encode_u8(7, hp)
	change.significance = 7

func disappeared(id : int):
	var change : Change = quick_access_changes[256 + id]
	change.code.resize(2)
	if change.significance == 0:
		changes[no_changes] = change
		no_changes += 1
	change.code.encode_u8(0, Utils.MessageType.DISAPPEARED)
	change.significance = 7

func position_changed(player : int, id : int, new_position : Vector2) -> void:
	var change : Change = quick_access_changes[256 * player + id]
	if change.significance > 0:
		match change.code.decode_u8(0):
			Utils.MessageType.SUMMONED_BUILT,\
			Utils.MessageType.SUMMONED_BUILT_OPP:
				change.code.encode_u16(3, roundi(new_position.x * 4))
				change.code.encode_u16(5, roundi(new_position.y * 4))
			Utils.MessageType.HP_CHANGE:
				change.code.resize(7)
				change.code.encode_u8(0, Utils.MessageType.POS_HP_CHANGE)
				change.code.encode_u8(6, change.code.decode_u8(2))
				change.code.encode_s16(2, roundi(new_position.x * 4))
				change.code.encode_s16(4, roundi(new_position.y * 4))
			Utils.MessageType.HP_CHANGE_OPP:
				change.code.resize(7)
				change.code.encode_u8(0, Utils.MessageType.POS_HP_CHANGE_OPP)
				change.code.encode_u8(6, change.code.decode_u8(2))
				change.code.encode_s16(2, roundi(new_position.x * 4))
				change.code.encode_s16(4, roundi(new_position.y * 4))
			_:
				change.significance = 1
				change.code.resize(6)
				change.code.encode_s16(2, roundi(new_position.x * 4))
				change.code.encode_s16(4, roundi(new_position.y * 4))
				if player == main_player:
					change.code.encode_u8(0, Utils.MessageType.POS_CHANGE)
				else:
					change.code.encode_u8(0, Utils.MessageType.POS_CHANGE_OPP)
	else:
		changes[no_changes] = change
		no_changes += 1
		change.significance = 1
		change.code.resize(6)
		change.code.encode_s16(2, roundi(new_position.x * 4))
		change.code.encode_s16(4, roundi(new_position.y * 4))
		if player == main_player:
			change.code.encode_u8(0, Utils.MessageType.POS_CHANGE)
		else:
			change.code.encode_u8(0, Utils.MessageType.POS_CHANGE_OPP)

#func hp_changed(player : int, id : int, new_hp : int, change_amount : int) -> void:
func hp_changed(player : int, id : int, new_hp : int) -> void:
	var change : Change = quick_access_changes[256 * player + id]
	var significance = 3
	if change.significance > 0:
		if change.significance < significance:
			change.significance = significance
		match change.code.decode_u8(0):
			Utils.MessageType.SUMMONED_BUILT,\
			Utils.MessageType.SUMMONED_BUILT_OPP:
				change.code.encode_u8(7, new_hp)
			Utils.MessageType.POS_CHANGE:
				change.code.resize(7)
				change.code.encode_u8(0, Utils.MessageType.POS_HP_CHANGE)
				change.code.encode_u8(6, new_hp)
			Utils.MessageType.POS_CHANGE_OPP:
				change.code.resize(7)
				change.code.encode_u8(0, Utils.MessageType.POS_HP_CHANGE_OPP)
				change.code.encode_u8(6, new_hp)
			Utils.MessageType.HP_CHANGE:
				change.code.encode_u8(2, new_hp)
			Utils.MessageType.HP_CHANGE_OPP:
				change.code.encode_u8(2, new_hp)
			_:
				change.code.resize(3)
				change.code.encode_u8(2, new_hp)
				if player == main_player:
					change.code.encode_u8(0, Utils.MessageType.HP_CHANGE)
				else:
					change.code.encode_u8(0, Utils.MessageType.HP_CHANGE_OPP)
	else:
		changes[no_changes] = change
		no_changes += 1
		change.significance = significance
		change.code.resize(3)
		change.code.encode_u8(2, new_hp)
		if player == main_player:
			change.code.encode_u8(0, Utils.MessageType.HP_CHANGE)
		else:
			change.code.encode_u8(0, Utils.MessageType.HP_CHANGE_OPP)

func upgraded(upgrade_type : Utils.MessageType, entity_type : Utils.EntityType, level : int) -> void:
	var idx : int = 512 + 3 * (entity_type - Utils.EntityType.CHARACTER_0) + upgrade_type - Utils.MessageType.UPGRADED_0
	var change : Change = quick_access_changes[idx]
	change.code.encode_u8(2, level)
	if change.significance == 0:
		changes[no_changes] = change
		no_changes += 1
	change.significance = 7
