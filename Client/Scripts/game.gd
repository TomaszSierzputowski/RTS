extends Node

# Prędkość przesuwania mapy (można dostosować)
var move_speed: float = 500.0
# Współczynnik zmiany skali
var zoom_speed: float = 0.1
# Minimalna i maksymalna skala
var min_scale: float = 0.25
var max_scale: float = 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var movement: Vector2 = Vector2.ZERO

	# Sprawdzenie naciśnięcia przycisków WASD
	"""if Input.is_action_pressed("move_up"):
		movement.y -= 1
	if Input.is_action_pressed("move_down"):
		movement.y += 1
	if Input.is_action_pressed("move_left"):
		movement.x -= 1
	if Input.is_action_pressed("move_right"):
		movement.x += 1"""

	# Normalizowanie i mnożenie przez prędkość i czas delta, by uzyskać płynny ruch
	#movement = movement.normalized() * move_speed * delta

	# Przesunięcie pozycji kamery
	#position += movement

# Called when an input event is detected
func _input(event: InputEvent) -> void:

	# Obsługa kliknięcia lewym przyciskiem myszy
	"""if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_position = event.position
		print("coordinates :", click_position)

	# Obsługa skalowania za pomocą kółka myszy
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in(event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out(event.position)"""

# Funkcja zwiększająca skalę z kotwiczeniem na pozycji myszy
"""func zoom_in(mouse_pos: Vector2) -> void:
	if scale.x < max_scale:
		apply_zoom(mouse_pos, zoom_speed)

# Funkcja zmniejszająca skalę z kotwiczeniem na pozycji myszy
func zoom_out(mouse_pos: Vector2) -> void:
	if scale.x > min_scale:
		apply_zoom(mouse_pos, -zoom_speed)

# Funkcja pomocnicza do skalowania względem pozycji myszy
func apply_zoom(mouse_pos: Vector2, zoom_delta: float) -> void:
	scale += Vector2(zoom_delta, zoom_delta)

	# Przesunięcie pozycji tak, aby mapa była skalowana względem pozycji kursora
	var offset = (mouse_pos - position) * zoom_delta
	position -= offset"""
