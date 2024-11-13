extends Object

class_name Building

var id: int
var position: Vector2
var owner_id: int
var size: Vector2

func _init(id: int, position: Vector2, owner_id: int, size: Vector2) -> void:
	self.id = id
	self.position = position
	self.owner_id = owner_id
	self.size = size

func is_at_position(pos: Vector2) -> bool:
	return position.x <= pos.x and pos.x < position.x + size.x and position.y <= pos.y and pos.y < position.y + size.y

func destroy() -> void:
	print("Building ID: " + str(id) + " has been destroyed.")
