extends Object
class_name Serializer

static func serialize_string(string : String) -> PackedByteArray:
	var txt : PackedByteArray = string.to_ascii_buffer()
	var packet : PackedByteArray
	packet.append(txt.size())
	txt = txt.compress()
	packet.append_array(txt)
	return packet

static func deserialize_string(packet : PackedByteArray) -> String:
	var size : int = packet[0]
	packet.remove_at(0)
	return packet.decompress(size).get_string_from_ascii()

static func serialize_strings(strings : Array[String]) -> PackedByteArray:
	var packet : PackedByteArray
	var txt : PackedByteArray
	for string in strings:
		txt = string.to_ascii_buffer()
		packet.append(txt.size())
		packet.append_array(txt)
	return packet

static func deserialize_strings(packet : PackedByteArray) -> Array[String]:
	var strings : Array[String]
	var s : int
	var e : int
	var size : int = packet.size()
	while s < size:
		e = s + packet[s]
		strings.append(packet.slice(s, e).get_string_from_ascii())
	return strings
