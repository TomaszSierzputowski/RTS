extends Object

class_name Character

var id: int
var position: Vector2
var speed: int = 100
var health: int = 100
var owner_id: int

func _init(id: int, position: Vector2, owner_id: int) -> void:
	self.id = id
	self.position = position
	self.owner_id = owner_id

func is_at_position(pos: Vector2) -> bool:
	return position == pos

func take_damage(amount: int) -> void:
	health -= amount
	if health < 0:
		health = 0
