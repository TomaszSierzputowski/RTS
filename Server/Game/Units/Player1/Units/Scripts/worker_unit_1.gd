extends CharacterBody2D

class_name WorkerUnit

@onready var nav_agent : NavigationAgent2D = $Navigation/NavigationAgent2D

var player: Player
var target_position: Vector2
var isAssignedToBuilding: bool = false

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
	nav_agent.set_velocity(intended_velocity)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = velocity.move_toward(safe_velocity,50)
	move_and_slide()


func _on_timer_timeout() -> void:
	recalc_path()

func recalc_path() -> void:
	if target_position:
		nav_agent.target_position = target_position
		
func move_to_point(point :Vector2):
	target_position = point
	recalc_path()
