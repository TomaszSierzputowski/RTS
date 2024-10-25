@tool
extends EditorPlugin

const MyExportPlugin = preload("res://addons/my_export_plugin/export-script.gd")
var export_plugin = MyExportPlugin.new()

func _enable_plugin() -> void:
	add_export_plugin(export_plugin)

func _disable_plugin() -> void:
	remove_export_plugin(export_plugin)
