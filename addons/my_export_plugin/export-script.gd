@tool
extends EditorExportPlugin

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	var file = FileAccess.open("res://.godot/extension_list.cfg", FileAccess.WRITE)
	file.store_string("res://addons/godot-sqlite/gdsqlite.gdextension")
	file.close()

func _export_end() -> void:
	var file = FileAccess.open("res://.godot/extension_list.cfg", FileAccess.WRITE)
	file.store_string("res://addons/godot-git-plugin/git_plugin.gdextension\nres://addons/godot-sqlite/gdsqlite.gdextension")
	file.close()
