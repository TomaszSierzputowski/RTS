extends Node2D

var db_path = "res://data/database.db"
var db = null

# Called when the node enters the scene tree for the first time.
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
