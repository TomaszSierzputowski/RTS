extends Node2D

# Sygnały do logowania i rejestracji
signal login_attempt(username, password) # await Client.sign_in(username, password)
signal register_attempt(username, password) # var err =  await Client.sign_in(-||-); if err == Utils.MessageType.RESPONSE_OK:

# Referencje do pól tekstowych i przycisków
@onready var username_field = $VBoxContainer2/username_field
@onready var password_field = $VBoxContainer2/password_field
@onready var login_button = $HBoxContainer2/login_button
@onready var register_button = $HBoxContainer2/register_button

func _on_login_button_pressed() -> void:
	var username = username_field.text
	var password = password_field.text
	
	# Emituje sygnał logowania
	login_attempt.emit(username, password)
	print("login button pressed")


func _on_register_button_pressed() -> void:
	var username = username_field.text
	var password = password_field.text
	
	# Emituje sygnał rejestracji
	register_attempt.emit(username, password)
	print("register button pressed")
