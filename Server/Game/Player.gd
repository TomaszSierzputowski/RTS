extends Node

class_name Player

# Podstawowe właściwości
var id: int
var characters: Array = []
var buildings: Array = []
var resources: Dictionary = {}

# Funkcja inicjalizująca
func _init(player_id: int) -> void:
	id = player_id
	characters = []
	buildings = []
	resources = {
		"Gold": 1000
	}
	
		# Subskrybowanie sygnału "destroyed" od budynków
	for building in buildings:
		building.connect("destroyed", self, "_on_building_destroyed")

# Funkcja odbierająca sygnał o zniszczeniu budynku
func _on_building_destroyed(building_id: int, owner_id: int) -> void:
	# Usuwanie budynku z listy, jeśli to budynek tego gracza
	if owner_id == id:
		for building in buildings:
			if building.id == building_id:
				buildings.erase(building)
				print("Budynek o ID:", building_id, "został usunięty z listy gracza.")
				return

# Dodawanie postaci do gracza
func add_character(character: Character) -> void:
	characters.append(character)

# Dodawanie budynku do gracza
func add_building(building: Building) -> void:
	buildings.append(building)

# Usuwanie postaci (np. po śmierci)
func remove_character(character: Character) -> void:
	characters.erase(character)

# Usuwanie budynku (np. po zniszczeniu)
func remove_building(building: Building) -> void:
	buildings.erase(building)

# Dodawanie zasobów (np. po zebraniu)
func add_resources(resource_type: String, amount: int) -> void:
	if resource_type in resources:
		resources[resource_type] += amount
		print("Gracz ID:", id, "dodał zasoby:", resource_type, "ilość:", amount)
	else:
		print("Nieznany typ zasobu:", resource_type)

# Odejmowanie zasobów (np. przy budowie)
func deduct_resources(resource_type: String, amount: int) -> bool:
	if resource_type in resources and resources[resource_type] >= amount:
		resources[resource_type] -= amount
		print("Gracz ID:", id, "odjął zasoby:", resource_type, "ilość:", amount)
		return true
	else:
		print("Nie ma wystarczających zasobów lub nieznany typ zasobu")
		return false

# Zarządzanie atakami postaci
func process_character_attacks() -> void:
	for character in characters:
		if character.state == Character.State.ATTACKING:
			character.attack_target(0.0)  # Możesz dostosować tę wartość (delta), jeśli wymaga to synchronizacji z czasem gry
