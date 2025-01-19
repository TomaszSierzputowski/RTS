extends Node2D

@onready var play_button = $Node/HBoxContainer/VBoxContainer2/play_button
@onready var delete_acc_button = $Node/HBoxContainer/VBoxContainer2/delete_acc_button
@onready var label = $Node/HBoxContainer/VBoxContainer/Label

#TODO nie działa :((((
func _ready() -> void:
	var previous_scene = get_tree().current_scene
	if previous_scene:
		if previous_scene.has_signal("login_attempt"):
			previous_scene.connect("login_attempt", Callable(self, "_on_login_attempt"))
		else:
			print("Previous scene does not have the signal 'login_attempt'")
	else:
		print("Previous scene is null")

func _on_login_attempt(username: String, password: String) -> void:
	label.text = "Witaj, " + username + "!"
	print(username)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Client/Scenes/map.tscn")
	
func _on_delete_acc_button_pressed() -> void:
	Database.delete_account(" ") #username
	get_tree().change_scene_to_file("res://Client/Scenes/login_menu.tscn")
