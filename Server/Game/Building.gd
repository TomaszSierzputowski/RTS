extends Object

class_name Building

# Podstawowe właściwości
var id: int
var owner_id: int
var position: Vector2
var size: Vector2
var health: int = 1000  # Początkowa wytrzymałość budynku
var max_health: int = 1000  # Maksymalna wytrzymałość budynku

# Funkcja inicjalizująca
func _init(building_id: int, start_position: Vector2, owner: int, building_size: Vector2) -> void:
	id = building_id
	position = start_position
	owner_id = owner
	size = building_size

# Otrzymywanie obrażeń
func take_damage(amount: int) -> void:
	health -= amount
	print("Budynek ID:", id, "otrzymał obrażenia:", amount, "pozostałe zdrowie:", health)
	if health <= 0:
		health = 0
		die()

# Logika śmierci budynku
func die() -> void:
	print("Budynek ID:", id, "został zniszczony")
	emit_signal("destroyed", id, owner_id)
	
func is_at_position(pos: Vector2) -> bool:
	return position.x <= pos.x and pos.x < position.x + size.x and position.y <= pos.y and pos.y < position.y + size.y





	
