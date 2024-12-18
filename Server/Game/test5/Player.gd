extends Node

# Lista jednostek gracza
var units : Array = []

# Dodaj jednostkę
func add_unit(unit_scene: PackedScene, position: Vector3):
	var unit = unit_scene.instantiate()
	unit.global_transform.origin = position
	add_child(unit)
	units.append(unit)

# Usuń jednostkę
func remove_unit(unit):
	if unit in units:
		units.erase(unit)
		unit.queue_free()
