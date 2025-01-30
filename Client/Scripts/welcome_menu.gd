extends Node2D

@onready var play_button = $Node/HBoxContainer/VBoxContainer2/play_button
@onready var delete_acc_button = $Node/HBoxContainer/VBoxContainer2/delete_acc_button
@onready var label = $Node/HBoxContainer/VBoxContainer/Label
@onready var window = $Window

func _ready() -> void:
	window.visible = false
	label.text = "Welcome, " + UserData.username + "!"
	self.visible = true


func _on_play_button_pressed() -> void:
	window.popup_centered()
	
	# zmiana sceny na jakieś "waiting for another player"
	var err = await Client.play()
	if err != Utils.MessageType.RESPONSE_OK:
		print("Cannot start game: ", err)
	else:
		get_tree().change_scene_to_file("res://Client/Scenes/game.tscn")
	
func _on_delete_acc_button_pressed() -> void:
	Database.delete_account(" ") #username
	get_tree().change_scene_to_file("res://Client/Scenes/login_menu.tscn")


func _on_window_close_requested() -> void:
	window.visible = false
	Client.cancel_play()
	#get_tree().change_scene_to_file("res://Client/Scenes/welcome_menu.tscn")

func _on_window_mouse_exited() -> void:
	pass # Replace with function body.
