extends StaticBody2D

class_name  StandardUnitFactory1

var HP: int = 100
var max_HP: int = 100
var id = -1

signal moved(player : int, id : int, new_position : Vector2)
signal damaged(player : int, id : int, hp : int)
signal died(player : int, id : int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(damage: int) -> void:
	HP -= damage
	if HP <= 0:
		#@warning_ignore("integer_division")
		died.emit(0, id)
		die()
	else:
		damaged.emit(0, id, HP * 100 / max_HP)

func die() -> void:
	queue_free()

func get_class_name() -> String:
	return "StandardUnitFactory"

func get_player_num() -> int:
	return 1
