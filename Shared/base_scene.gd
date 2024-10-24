extends Node

func _ready() -> void:
	if OS.has_feature("server"):
		get_tree().call_deferred("change_scene_to_file", "res://Server/server_base.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://Client/Scenes/main_menu.tscn")
