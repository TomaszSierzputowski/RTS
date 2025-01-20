extends Node2D

var db_path = "res://data/database.db"
var db = null

func _ready() -> void:
	db = SQLite.new()
	db.set_path(db_path)
	if not db.open_db():
		_log_message("Failed to open Database.")
		return
	_create_tables()

func _create_tables():
	_execute_query("""
	CREATE TABLE IF NOT EXISTS players(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		username TEXT NOT NULL,
		password TEXT NOT NULL,
		salt TEXT NOT NULL
	);""", "Failed to create players table."
	)

func _log_message(message: String):
	print(message)

func _execute_query(query: String, error_message: String):
	if not db.query(query):
		_log_message(error_message + ": " + db.get_error_message())
		push_error(error_message + ": " + db.get_error_message())
		return false
	return true

func _insert_record(query: String, params: Array, error_message: String) -> int:
	if not db.query_with_bindings(query, params):
		_log_message(error_message + ": " + db.get_error_message())
		return -1
	else:
		return db.get_last_insert_rowid()
		
func _get_record(query: String, params: Array, error_message: String) -> Dictionary:
	if not db.query_with_bindings(query, params):
		_log_message(error_message + ": " + db.get_error_message())
		return {}
	var result = db.get_query_result()
	if result.size() > 0:
		return result[0]
	else:
		_log_message(error_message + ": No records found.")
		return {}

func _update_record(query: String, params: Array, error_message: String) -> bool:
	if not db.query_with_bindings(query, params):
		_log_message(error_message + ": " + db.get_error_message())
		return false
	return true

func _delete_record(query: String, params: Array, error_message: String):
	if not db.query_with_bindings(query, params):
		_log_message(error_message + ": " + db.get_error_message())

func create_account(username: String, hashed_password: String, salt: String) -> Utils.MessageType:
	var existing_user = _get_record(
		"SELECT * FROM players WHERE username = ?",
		[username],
		"Failed to check existing username"
	)
	if existing_user.size() > 0:
		_log_message("Username already exists.")
		return Utils.MessageType.ERROR_LOGIN_ALREADY_IN_DATABASE
		
	var err = _insert_record(
		"INSERT INTO players (username, password, salt) VALUES (?, ?, ?)",
		[username, hashed_password, salt],
		"Failed to create account"
	)
	
	if err < 0:
		return Utils.MessageType.ERROR_INVALID_LOGIN
	return Utils.MessageType.RESPONSE_OK

func get_account_info(username: String) -> Array:
	var existing_user = _get_record(
		"SELECT * FROM players WHERE username = ?",
		[username],
		"Failed to check existing username"
	)
	if existing_user.size() == 0:
		_log_message("Invalid input: username must not be empty.")
		return [Utils.MessageType.ERROR_INVALID_LOGIN]
	
	var user_data = _get_record(
		"SELECT id, password, salt FROM players WHERE username = ?",
		[username],
		"Failed to retrieve account info"
	)
	if user_data.size() == 0:
		_log_message("Account not found for username: " + username) 
		return [Utils.MessageType.ERROR_LOGIN_NOT_IN_DATABASE]
	
	return [Utils.MessageType.RESPONSE_OK, user_data["id"], user_data["password"], user_data["salt"]]

func delete_account(username: String):
	_delete_record("DELETE FROM players WHERE username = ?",
	[username],
	"Failed to delete player"
	)
