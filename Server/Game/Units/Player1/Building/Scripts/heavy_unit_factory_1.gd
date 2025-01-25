extends StaticBody2D

class_name  HeavyUnitFactory

var ID: int
var HP: int = 100
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(damage: int) -> void:
	HP -= damage
	if HP <= 0:
		die()

func die() -> void:
	queue_free()
