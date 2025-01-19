class_name WorkerUnit_1

extends CharacterBody2D

@export var nav_agent: NavigationAgent2D
@export var tolerance_distance: float = 50

var player: Player

var target_position: Vector2 = Vector2.ZERO
var target_building: Node = null
var targeted_buildings: Array = []

# STATS
#----------------------------------
@export var hp: int = 100
@export var max_hp: int = 100
@export var defense: int = 5
@export var speed: float = 100.0
#----------------------------------

var navigation_map : RID

func setup(start_position: Vector2, unit_hp: int, unit_max_hp: int, unit_defense: int, unit_weapon_damage: int, unit_speed: float) -> void:
	global_position = start_position
	hp = unit_hp
	max_hp = unit_max_hp
	defense = unit_defense
	speed = unit_speed

func _ready() -> void:
	nav_agent.path_desired_distance = 20
	nav_agent.target_desired_distance = 20

func _physics_process(delta: float) -> void:
	if target_position != Vector2.ZERO and global_position.distance_to(target_position) < tolerance_distance:
		target_position = Vector2.ZERO
		recalc_path()

	if target_building and not is_instance_valid(target_building):
		if global_position.distance_to(target_building.global_position) < tolerance_distance:
			target_building = null
			recalc_path()

	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = axis * speed
	move_and_slide()

func recalc_path() -> void:
	if target_position != Vector2.ZERO:
		nav_agent.target_position = target_position
	elif target_building and is_instance_valid(target_building):
		if global_position.distance_to(target_building.global_position) > tolerance_distance:
			set_random_target(50, 250)
		else:
			nav_agent.target_position = global_position
	elif not targeted_buildings.is_empty():
		target_building = find_closest_building()
		if target_building and not is_instance_valid(target_building):
			if global_position.distance_to(target_building.global_position) > tolerance_distance:
				set_random_target(50, 250)
		else:
			nav_agent.target_position = global_position
	else:
		nav_agent.target_position = global_position

func find_closest_building() -> Node2D:
	var closest_node: Node2D = null
	var closest_distance: float = INF
	
	for node in targeted_buildings:
		if node and is_instance_valid(node):
			var distance = global_position.distance_to(node.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_node = node

	return closest_node
	
func is_valid(point: Vector2):
	var tilemap = get_parent().get_node("TileMapLayer")
	if tilemap:
		point.x+=2000
		point.y-=7000
		point = tilemap.local_to_map(point)
		var cell_id = tilemap.get_cell_source_id(point)
		if cell_id == 2:
			return false
	return true

func take_damage(damage: int) -> void:
	hp -= damage
	if hp <= 0:
		die()

func die() -> void:
	queue_free()

func update_target_building() -> void:
	if target_building == null and not targeted_buildings.is_empty():
		target_building = find_closest_building()


func set_random_target(min_distance: float, max_distance: float) -> void:
	var distance = randf_range(min_distance, max_distance)
	var angle = randf_range(0, TAU)
	if is_instance_valid(target_building):
		var building_position = target_building.global_position
		var new_target = building_position + Vector2( cos(angle) * distance, sin(angle) * distance)
		if not is_valid(new_target):
			target_position = new_target
			
func get_cell_id(point: Vector2):
	var tilemap = get_parent().get_node("TileMapLayer")
	if tilemap:
		point = tilemap.local_to_map(point)
		var cell_id = tilemap.get_cell_source_id(point)
		if cell_id != -1:
			return cell_id
	return -1
	

func _on_recalculate_timer_timeout() -> void:
	if get_cell_id(self.position) == 2:
		player.add_resource(1)
	if target_building:
		set_random_target(50, 250)
		recalc_path()

func _on_connection_zone_body_entered(body: Node2D) -> void:
	if target_building == null and body is StaticBody2D:
		targeted_buildings.append(body)
		target_building = body

func _on_connection_zone_body_exited(body: Node2D) -> void:
	if body in targeted_buildings:
		targeted_buildings.erase(body)
