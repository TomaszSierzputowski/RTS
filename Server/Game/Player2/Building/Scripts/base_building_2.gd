extends StaticBody2D

class_name BaseBuilding2

var HP: int = 1000
var max_HP: int = 1000
var MaxWorkers: int = 10
var currentWorkers: Array
var id = -1

signal moved(player : int, id : int, new_position : Vector2)
signal damaged(player : int, id : int, hp : int)
signal died(player : int, id : int)

func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("get_class_name"):
		if body.get_class_name() == "WorkerUnit" and currentWorkers.size() < MaxWorkers:
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
		if !is_valid(worker.position):
			worker.player.add_resource(1)

func is_valid(point: Vector2) -> bool:
	var tileMapLayer = get_parent().get_node("TileMapLayer")
	if tileMapLayer:
		var cell_id = tileMapLayer.get_tile_id(point)
		if cell_id == 2:
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
			worker.move_to_position(new_target)

func take_damage(damage: int) -> void:
	HP -= damage
	if HP <= 0:
		#@warning_ignore("integer_division")
		died.emit(1, id)
		die()
	else:
		damaged.emit(1, id, HP * 100 / max_HP)

func die() -> void:
	queue_free()

func get_class_name() -> String:
	return "Base"
	
func get_player_num() -> int:
	return 2
