extends Node

func _ready() -> void:
	if OS.has_feature("server"):
		var scene = load("res://Server/server_base.tscn").instantiate()
		call_deferred("add_child", scene)
	else:
		var scene = load("res://Client/Scenes/main_menu.tscn").instantiate()
		call_deferred("add_child", scene)
