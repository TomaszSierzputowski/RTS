extends Object
class_name Serializer

static func serialize_string(string : String) -> PackedByteArray:
	var packet : PackedByteArray = string.to_ascii_buffer()
	return compress(packet)

static func deserialize_string(packet : PackedByteArray) -> String:
	return decompress(packet).get_string_from_ascii()

static func serialize_strings(strings : Array[String]) -> PackedByteArray:
	var packet : PackedByteArray
	var txt : PackedByteArray
	for string in strings:
		txt = string.to_ascii_buffer()
		packet.append(txt.size())
		packet.append_array(txt)
	return compress(packet)

static func deserialize_strings(packet : PackedByteArray) -> Array[String]:
	packet = decompress(packet)
	var strings : Array[String]
	var s : int = 0
	var e : int = s + packet[s]
	strings.append(packet.slice(s + 1, e).get_string_from_ascii())
	var size : int = packet.size()
	while e < size:
		s = packet[e]
		e = s + packet[s]
		strings.append(packet.slice(s + 1, e).get_string_from_ascii())
	return strings

static func compress(packet : PackedByteArray) -> PackedByteArray:
	packet = packet.compress()
	var compressed : PackedByteArray
	compressed.append(packet.size())
	compressed.append_array(packet)
	return compressed

static func decompress(packet : PackedByteArray) -> PackedByteArray:
	var size : int = packet[0]
	packet.remove_at(0)
	return packet.decompress(size)
