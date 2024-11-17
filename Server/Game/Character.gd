extends Object

class_name Character

# Podstawowe właściwości
var id: int
var owner_id: int
var position: Vector2
var target_position: Vector2
var health: int = 100
var max_health: int = 100
var attack_damage: int = 10
var attack_range: float = 50.0  # Zasięg ataku
var attack_cooldown: float = 1.0  # Czas między atakami
var speed: float = 100.0  # Jednostki na sekundę

# Stan wewnętrzny
enum State { IDLE, MOVING, ATTACKING }
var state: State = State.IDLE
var attack_timer: float = 0.0
var target_character: Character = null

# Funkcja inicjalizująca
func _init(character_id: int, start_position: Vector2, owner: int) -> void:
	id = character_id
	owner_id = owner
	position = start_position

# Aktualizacja logiki postaci
func _process(delta: float) -> void:
	match state:
		State.IDLE:
			look_for_targets()
		State.MOVING:
			move_towards_target(delta)
		State.ATTACKING:
			attack_target(delta)

# Szukanie celów w zasięgu
func look_for_targets() -> void:
	var closest_enemy = find_closest_enemy()
	if closest_enemy and position.distance_to(closest_enemy.position) <= attack_range:
		target_character = closest_enemy
		state = State.ATTACKING
	elif target_position != position:
		state = State.MOVING

# Poruszanie się w kierunku celu
func move_towards_target(delta: float) -> void:
	if position.distance_to(target_position) < 5.0:
		position = target_position
		state = State.IDLE
		return

	var direction = (target_position - position).normalized()
	position += direction * speed * delta
	if target_character and position.distance_to(target_character.position) <= attack_range:
		state = State.ATTACKING

# Atakowanie celu
func attack_target(delta: float) -> void:
	if target_character and target_character.health > 0:
		attack_timer -= delta
		if attack_timer <= 0.0:
			target_character.take_damage(attack_damage)
			attack_timer = attack_cooldown
			if target_character.health <= 0:
				print("Postać ID:", target_character.id, "zginęła")
				target_character = null
				state = State.IDLE
	else:
		target_character = null
		state = State.IDLE

# Otrzymywanie obrażeń
func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		health = 0
		die()

# Logika śmierci
func die() -> void:
	print("Postać ID:", id, "zginęła")
	
func is_at_position(pos: Vector2) -> bool:
	return position == pos

# Znajdowanie najbliższego przeciwnika
func find_closest_enemy() -> Character:
	var closest_enemy: Character = null
	var closest_distance: float = INF
	
	#...
	
	return closest_enemy
