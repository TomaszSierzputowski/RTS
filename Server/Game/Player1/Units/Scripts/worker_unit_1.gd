extends CharacterBody2D

class_name WorkerUnit

@onready var nav_agent : NavigationAgent2D = $Navigation/NavigationAgent2D

var player: Player
var target_position: Vector2
var isAssignedToBuilding: bool = false
var id = -1

signal moved(player : int, id : int, new_position : Vector2)
signal damaged(player : int, id : int, hp : int)
signal died(player : int, id : int)

# STATS
#----------------------------------
@export var hp: int = 100
@export var max_hp: int = 100
@export var speed: float = 100.0
#----------------------------------

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		target_position = Vector2.ZERO
		return
	
	
	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	var intended_velocity = axis * speed
	velocity = intended_velocity
	if velocity.length() > 0:
		move_and_slide()
		moved.emit(0, id, position)

func take_damage(damage1: int) -> void:
	hp -= damage1
	if hp <= 0:
		#@warning_ignore("integer_division")
		died.emit(0, id)
		die()
	else:
		damaged.emit(0, id, hp * 100 / max_hp)

func die() -> void:
	queue_free()


func _on_timer_timeout() -> void:
	recalc_path()

func recalc_path() -> void:
	if target_position:
		nav_agent.target_position = target_position
		
func move_to_position(new_position :Vector2):
	target_position = new_position
	recalc_path()

func get_class_name() -> String:
	return "WorkerUnit"

func get_player_num() -> int:
	return 1
