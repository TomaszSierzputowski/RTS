class_name CombatUnit_1

extends CharacterBody2D

@export var nav_agent: NavigationAgent2D
@export var de_agro_distance = 100
@export var tolerance_distance = 50

var target_node: Node = null
var targeted_character: Array = []
var target_position: Vector2 = Vector2.ZERO

# STATS
#----------------------------------
@export var hp: int = 100
@export var max_hp: int = 100
@export var defense: int = 5
@export var weapon_damage: int = 10
@export var speed: float = 100.0
#----------------------------------

func setup(start_position: Vector2, unit_hp: int, unit_max_hp: int, unit_defense: int, unit_weapon_damage: int, unit_speed: float) -> void:
	global_position = start_position
	hp = unit_hp
	max_hp = unit_max_hp
	defense = unit_defense
	weapon_damage = unit_weapon_damage
	speed = unit_speed

func _ready() -> void:
	nav_agent.path_desired_distance = 20
	nav_agent.target_desired_distance = 20



func _physics_process(delta: float) -> void:
	clean_targeted_characters()
	
	if target_position and global_position.distance_to(target_position) < tolerance_distance:
		target_position = Vector2.ZERO
		recalc_path()

	if target_node and is_instance_valid(target_node):		
		if global_position.distance_to(target_node.global_position) < de_agro_distance:
			check_and_attack()	
			recalc_path()
			target_node = null
		elif not targeted_character.is_empty():  
			if target_node != targeted_character[0]:
				target_node = targeted_character[0]
				recalc_path()
	
	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = axis * speed
	move_and_slide()

func recalc_path() -> void:
	clean_targeted_characters()
	
	if target_position:
		nav_agent.target_position = target_position
	elif not target_node:
		if not targeted_character.is_empty():
			target_node = find_closest_node()
			if global_position.distance_to(target_node.global_position) > de_agro_distance:
				nav_agent.target_position = target_node.global_position
		else:
			nav_agent.target_position = global_position
	elif target_node and not targeted_character.is_empty():
		if global_position.distance_to(target_node.global_position) > de_agro_distance:
			nav_agent.target_position = target_node.global_position
		else:
			nav_agent.target_position = global_position
	else:
		nav_agent.target_position = global_position

func clean_targeted_characters() -> void:
	targeted_character = targeted_character.filter(is_instance_valid)

func find_closest_node() -> Node2D:
	var closest_node = null
	var closest_distance = INF  # Używamy nieskończoności na początku, aby znaleźć najmniejszą odległość

	# Iteracja przez wszystkie węzły i obliczanie odległości
	for node in targeted_character:
		var distance = position.distance_to(node.position)
		if distance < closest_distance:
			closest_distance = distance
			closest_node = node

	return closest_node

func _on_recalculate_timer_timeout() -> void:
	recalc_path()

func _on_agrro_range_area_entered(area: Area2D) -> void:
	print(area.owner)
	if area.owner not in targeted_character:
		targeted_character.append(area.owner)

func sort_by_distance(node_a: Node, node_b: Node) -> int:		
	if not is_instance_valid(node_a) or not is_instance_valid(node_b):
		return 0
	
	var dist_a = node_a.global_position.distance_to(global_position)
	var dist_b = node_b.global_position.distance_to(global_position)
	
	return -1 if dist_a < dist_b else 1 if dist_a > dist_b else 0

func _on_de_agrro_range_area_exited(area: Area2D) -> void:
	if not targeted_character.is_empty() and area.owner in targeted_character:
		targeted_character.erase(area.owner)
		recalc_path()

func deal_damage(target: CharacterBody2D) -> void:
	if not target.has_method("take_damage"):
		return
	
	var damage = max(0, weapon_damage - target.defense)  # Minimal damage is 0
	target.take_damage(damage)

func check_and_attack() -> void:
	if target_node and global_position.distance_to(target_node.global_position) <= tolerance_distance:
		deal_damage(target_node)

func take_damage(damage: int) -> void:
	hp -= damage
	if hp <= 0:
		die()

func die() -> void:
	queue_free()
