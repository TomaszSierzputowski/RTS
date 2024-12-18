extends CharacterBody2D

@export var nav_agent: NavigationAgent2D
@export var de_agro_distance = 30
@export var tolerance_distance = 30

var target_node
var targeted_character = []
var target_position = null

# STATS
#----------------------------------
@export var hp : int = 100
@export var max_hp : int = 100
@export var defense : int = 5
@export var weapon_damage : int = 10
@export var speed = 100
#----------------------------------

#func _init(start_position: Vector2,unit_hp: int,unit_max_hp: int, unit_defense: int, unit_weapon_damage: int, unit_speed: int) -> void:
	#global_position = start_position
	#hp = unit_hp
	#max_hp = unit_max_hp
	#defense = unit_defense
	#weapon_damage = unit_weapon_damage
	#speed = unit_speed
	
func _ready():
	nav_agent.path_desired_distance =  20
	nav_agent.target_desired_distance = 20
	
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	clean_targeted_characters()  # Oczyść listę ze usuniętych obiektów
	
	if target_position:
		if global_position.distance_to(target_position) < tolerance_distance:
			target_position = null
			recalc_path()
	
	if target_node and is_instance_valid(target_node):
		targeted_character.sort_custom(sort_by_distance)
		if global_position.distance_to(target_node.global_position) < de_agro_distance:
			check_and_attack()
			target_node=null
			targeted_character.sort_custom(sort_by_distance)
			recalc_path()
		elif target_node != targeted_character[0]:
			target_node = targeted_character[0]
			recalc_path()

	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = axis * speed
	move_and_slide()

	

func recalc_path():
	clean_targeted_characters()
	if target_position:
		nav_agent.target_position = target_position
	elif not target_node:
		if not targeted_character.is_empty():
			target_node = targeted_character[0]
			if  global_position.distance_to(target_node.global_position) > de_agro_distance:
				nav_agent.target_position = target_node.global_position
		else:
			nav_agent.target_position = self.global_position
				
	elif target_node and not targeted_character.is_empty():
		if  global_position.distance_to(target_node.global_position) > de_agro_distance:
			nav_agent.target_position = target_node.global_position
		else:
			nav_agent.target_position = self.global_position
	else:
		nav_agent.target_position = self.global_position

func clean_targeted_characters() -> void:
	targeted_character = targeted_character.filter(is_instance_valid)

func _on_recalculate_timer_timeout() -> void:
	recalc_path()

func _on_agrro_range_area_entered(area: Area2D) -> void:
	if not area.owner in targeted_character:
		targeted_character.append(area.owner)
		targeted_character.sort_custom(sort_by_distance)

func sort_by_distance(node_a: Node, node_b: Node) -> int:
	if not is_instance_valid(node_a) or not is_instance_valid(node_b):
		return 0  

	var dist_a = node_a.position.distance_to(self.global_position)
	var dist_b = node_b.position.distance_to(self.global_position)
	
	if dist_a < dist_b:
		return -1 
	elif dist_a > dist_b:
		return 1   
	else:
		return 0   
		
func _on_de_agrro_range_area_exited(area: Area2D) -> void:
	if not targeted_character.is_empty():
		if area.owner in targeted_character:
			targeted_character.erase(area.owner)
			recalc_path()
		
		
func deal_damage(target: CharacterBody2D) -> void:
	if not target.has_method("take_damage"):
		return  
	
	var damage = weapon_damage - target.defense
	damage = max(0, damage)  # Minimalne obrażenia to 0
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
	
# Obsługa kliknięcia myszą
#func _input(event):
	#if event is InputEventMouseButton and event.pressed:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#var clicked_position = get_global_mouse_position()
			#target_position = clicked_position
			#print("2")
			#print(targeted_character)
			#print(target_node)
			#recalc_path()
		
