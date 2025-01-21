extends Label

var elapsed_time: float = 0.0

func _ready():
	elapsed_time = 0.0

func _process(delta: float):
	elapsed_time += delta
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	text = "%d:%02d" % [minutes, seconds]
