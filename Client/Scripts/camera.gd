extends Camera2D

var zoomSpeed : float = 10

var zoomTarget :Vector2

var maxZoom = Vector2(0.5, 0.5)
var minZoom = Vector2(1.5, 1.5)

var minPosition = Vector2(-3760, -5390)
var maxPosition = Vector2(3760, 5390)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoomTarget = zoom
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:


	Zoom(delta)
	KeysControl(delta)
	
func Zoom(delta):
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoomTarget *=1.1
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoomTarget *= 0.9
		
	zoomTarget.x = clamp(zoomTarget.x, maxZoom.x, minZoom.x)
	zoomTarget.y = clamp(zoomTarget.y, maxZoom.y, minZoom.y)

	zoom = zoom.slerp(zoomTarget, zoomSpeed * delta)
	
func KeysControl(delta):
	var moveAmount = Vector2.ZERO

	# Sprawdzanie wciśniętych klawiszy i ustawianie wektora ruchu
	if Input.is_action_pressed("camera_move_right"):
		moveAmount.x += 10
	if Input.is_action_pressed("camera_move_left"):
		moveAmount.x -= 10
	if Input.is_action_pressed("camera_move_up"):
		moveAmount.y -= 10
	if Input.is_action_pressed("camera_move_down"):
		moveAmount.y += 10

	moveAmount = moveAmount.normalized()
	position += moveAmount * delta * 700 * (1 / zoom.x)

	position.x = clamp(position.x, minPosition.x, maxPosition.x)
	position.y = clamp(position.y, minPosition.y, maxPosition.y)

	
func ClickAndDrag():
	pass
