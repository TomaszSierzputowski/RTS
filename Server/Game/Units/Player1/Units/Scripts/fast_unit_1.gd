class_name FastUnit_1

extends CharacterBody2D

@export var nav_agent: NavigationAgent2D
var target_position: Vector2 = Vector2.ZERO
var target_node: Node
var targeted_nodes: Array[Node] = []

# STATS
#----------------------------------
@export var hp: int = 50
@export var max_hp: int = 50
@export var speed: float = 150.0
@export var damage: float = 1.0
#----------------------------------

func _ready() -> void:
	pass



func _physics_process(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		target_position = Vector2.ZERO
		target_node = null
		recalc_path()
		return
	
	
	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	var intended_velocity = axis * speed
	nav_agent.set_velocity(intended_velocity)

func find_closest_node() -> Node2D:
	var closest_node = null
	var closest_distance = INF  #

	# Iteracja przez wszystkie węzły i obliczanie odległości
	for node in targeted_nodes:
		var distance = position.distance_to(node.position)
		if distance < closest_distance:
			closest_distance = distance
			closest_node = node

	return closest_node

func recalc_path() -> void:
	if target_position:
		nav_agent.target_position = target_position
	elif target_node:
		nav_agent.target_position = target_node.position
	elif not targeted_nodes.is_empty():
		target_node = find_closest_node()
		nav_agent.target_position = target_node.position


func deal_damage(target: CharacterBody2D) -> void:
	if not target.has_method("take_damage"):
		return
	target.take_damage(damage)

func take_damage(damage: int) -> void:
	hp -= damage
	if hp <= 0:
		die()

func die() -> void:
	queue_free()


func _on_agrro_range_body_entered(body: Node2D) -> void:
	if body not in targeted_nodes:
		targeted_nodes.append(body)

func _on_agrro_range_body_exited(body: Node2D) -> void:
	if body in targeted_nodes:
		targeted_nodes.erase(body)
		recalc_path()
	
func _on_de_agrro_range_body_entered(body: Node2D) -> void:
	target_node = null
