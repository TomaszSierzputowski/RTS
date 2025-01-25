extends StaticBody2D

class_name BaseBuilding

var ID: int
var HP: int = 1000
var MaxWorkers: int = 10
var currentWorkers: Array

func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name.substr(0,"WorkerUnit".length()) == "WorkerUnit" and currentWorkers.size() < MaxWorkers:
		if body.isAssignedToBuilding == false:
			currentWorkers.append(body)
			body.isAssignedToBuilding = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body in currentWorkers:
		currentWorkers.erase(body)
		body.isAssignedToBuilding = false


func _on_timer_timeout() -> void:
	for worker in currentWorkers:
		manage_workers()
		worker.player.add_resource(1)

func is_valid(point: Vector2) -> bool:
	var tileMapLayer = get_parent().get_node("TileMapLayer")
	if tileMapLayer:
		var cell_id = tileMapLayer.get_tile_id(point)
		if cell_id == 2:
			return false
			
	for child in get_parent().get_children():
		if round(child.position.distance_to(point)) == 0:
			return false
			
	return true


func manage_workers() -> void:
	var min_distance: float = 200.0
	var max_distance: float = 400.0
	for worker in currentWorkers:
		var distance = randf_range(min_distance, max_distance)
		var angle = randf_range(0, TAU)
		var new_target = self.global_position + Vector2( cos(angle) * distance, sin(angle) * distance)
		if not is_valid(new_target):
			worker.move_to_point(new_target)

func take_damage(damage: int) -> void:
	HP -= damage
	if HP <= 0:
		die()

func die() -> void:
	queue_free()
