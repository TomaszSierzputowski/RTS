extends Node2D

signal login_attempt(username, password) 
signal register_attempt(username, password)

@onready var sign_in_button = $Node/buttons_hbox/sign_in_button
@onready var sign_up_button = $Node/buttons_hbox/sign_up_button

@onready var login_go_button = $Node/data_vbox/data_hbox/login_vbox/login_go_button
@onready var register_go_button = $Node/data_vbox/data_hbox/register_vbox/register_go_button

@onready var login_vbox = $Node/data_vbox/data_hbox/login_vbox
@onready var login_username = $Node/data_vbox/data_hbox/login_vbox/login_username
@onready var login_password = $Node/data_vbox/data_hbox/login_vbox/login_password

@onready var register_vbox = $Node/data_vbox/data_hbox/register_vbox
@onready var register_username = $Node/data_vbox/data_hbox/register_vbox/register_username
@onready var register_password1 = $Node/data_vbox/data_hbox/register_vbox/register_password1
@onready var register_password2 = $Node/data_vbox/data_hbox/register_vbox/register_password2

@onready var label_error = $Node/data_vbox/label_error

func _ready() -> void:
	self.visible = true

func update_label(new_text: String):
	label_error.text = new_text

func _on_sign_in_button_pressed() -> void:
	#print("login button pressed")
	label_error.visible = false
	register_vbox.visible = false
	login_vbox.visible = true

func _on_sign_up_button_pressed() -> void:
	#print("register button pressed")
	label_error.visible = false
	register_vbox.visible = true
	login_vbox.visible = false

func _on_login_go_button_pressed() -> void:
	var username = login_username.text
	var password = login_password.text
	
	if check_password(password) and check_username(username):
		var response =  Utils.MessageType.RESPONSE_OK# await Client.sign_in(username, password)
		
		if response == Utils.MessageType.RESPONSE_OK:
			UserData.username = username
			login_attempt.emit(username, password)
			get_tree().change_scene_to_file("res://Client/Scenes/welcome_menu.tscn")
			
		else:
			update_label(str(response))
			label_error.visible = true
	else:
		update_label("Wrong data")
		label_error.visible = true

func _on_register_go_button_pressed() -> void:
	var username = register_username.text
	var password1 = register_password1.text
	var password2 = register_password2.text
	
	if password1 == password2:
		if check_password(password1) and check_password(password2) and check_username(username):
			var response = await Client.sign_up(username, password1, "placeholder") 
			if response == Utils.MessageType.RESPONSE_OK:
				register_attempt.emit(username, password1, password2)
				update_label("Now you are in our database hehe :O Don't be shy- sign in.")
			else:
				update_label(str(response))
				label_error.visible = true
		else:
			update_label("Wrong data!")
			label_error.visible = true
	else:
		update_label("Passwords have to be the same!")
		label_error.visible = true

func _is_valid_text(text: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9_\\-\\.\\!\\#\\$\\&]+$")
	return regex.search(text) != null
	
func check_username(username: String) -> bool:
	username = username.strip_edges()
	if username.length() < 1 or username.length() > 20:
		#print("Invalid username: length must be between 1 and 20 characters.")
		return false
	if not _is_valid_text(username):
		#print("Invalid username: contains invalid characters.")
		return false
	return true
	
func check_password(password: String) -> bool:
	password = password.strip_edges()
	if password.length() < 8 or password.length() > 20:
		#print("Invalid password: length must be between 3 and 20 characters.")
		return false
	if not _is_valid_text(password):
		#print("Invalid password: contains invalid characters.")
		return false
	return true
