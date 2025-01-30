extends Control

var dragging = false
var drag_start = Vector2.ZERO
var current_mouse_pos = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start = get_global_mouse_position()
			else:
				dragging = false
				queue_redraw()

	elif event is InputEventMouseMotion and dragging:
		current_mouse_pos = get_global_mouse_position()
		queue_redraw()


func _draw():
	if dragging:
		var top_left = Vector2(min(drag_start.x, current_mouse_pos.x), min(drag_start.y, current_mouse_pos.y))
		var size = Vector2(abs(current_mouse_pos.x - drag_start.x), abs(current_mouse_pos.y - drag_start.y))

		draw_rect(Rect2(top_left, size), Color(1, 1, 0, 0.3), true)
		draw_rect(Rect2(top_left, size), Color.YELLOW, false, 2)
