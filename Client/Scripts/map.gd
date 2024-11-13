extends Node2D

# Prędkość przesuwania mapy (można dostosować)
var move_speed: float = 500.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var movement: Vector2 = Vector2.ZERO

	# Sprawdzenie naciśnięcia przycisków WASD
	if Input.is_action_pressed("move_up"):
		movement.y -= 1
	if Input.is_action_pressed("move_down"):
		movement.y += 1
	if Input.is_action_pressed("move_left"):
		movement.x -= 1
	if Input.is_action_pressed("move_right"):
		movement.x += 1

	# Normalizowanie i mnożenie przez prędkość i czas delta, by uzyskać płynny ruch
	movement = movement.normalized() * move_speed * delta

	# Przesunięcie pozycji kamery
	position += movement

# Called when an input event is detected
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_position = event.position
		print("coordinates :", click_position)
