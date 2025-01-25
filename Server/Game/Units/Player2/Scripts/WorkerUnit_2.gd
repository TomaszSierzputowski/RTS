class_name WorkerUnit_2

extends CharacterBody2D

@onready var nav_agent : NavigationAgent2D = $Navigation/NavigationAgent2D
@export var tolerance_distance: float = 50

var player: Player

var target_position: Vector2 = Vector2.ZERO
var target_building: Node = null
var targeted_buildings: Array = []

# STATS
#----------------------------------
@export var hp: int = 100
@export var max_hp: int = 100
@export var speed: float = 100.0
#----------------------------------

var navigation_map : RID

func setup(start_position: Vector2, unit_hp: int, unit_max_hp: int, unit_speed: float) -> void:
	global_position = start_position
	hp = unit_hp
	max_hp = unit_max_hp
	speed = unit_speed

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	if target_position != Vector2.ZERO and global_position.distance_to(target_position) < tolerance_distance:
		target_position = Vector2.ZERO
		recalc_path()
		
	if target_building:
		if global_position.distance_to(target_building.global_position) < tolerance_distance:
			target_building = null
			recalc_path()
	
	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = axis * speed 

func recalc_path() -> void:
	if target_position != Vector2.ZERO:
		nav_agent.target_position = target_position
	elif target_building:
		if global_position.distance_to(target_building.global_position) > tolerance_distance:
			set_random_target(50, 250)
	elif not targeted_buildings.is_empty():
		target_building = find_closest_building()
		recalc_path()

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
		
	

func _on_recalculate_timer_timeout() -> void:
	if !is_valid(self.position) and player:
		player.add_resource(1)
	
	recalc_path()

func _on_connection_zone_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		targeted_buildings.append(body)
		target_building = body

func _on_connection_zone_body_exited(body: Node2D) -> void:
	if body in targeted_buildings:
		targeted_buildings.erase(body)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = velocity.move_toward(safe_velocity,25)
	move_and_slide()
