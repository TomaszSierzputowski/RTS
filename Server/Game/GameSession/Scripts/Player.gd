extends Node

class_name Player

# Lista jednostek gracza
var units: Array = []
var resources: int = 100

var WorkerUnitCost: int = 25
var CombatUnitCost: int = 50
var BuildingCost: int = 100

# Lista odblokowanych jednostek
var unlocked_units: Array = ["WorkerUnit"]  

# Funkcja dodająca jednostkę do gracza
func add_unit(unit: Node):
	if unit.name.substr(0,"WorkerUnit".length()) == "WorkerUnit" and "WorkerUnit" in unlocked_units and resources - WorkerUnitCost >= 0:
		resources-=WorkerUnitCost
		units.append(unit)
		_unlock_building()
		
	if unit.name.substr(0,"CombatUnit".length()) == "CombatUnit" and "CombatUnit" in unlocked_units and resources - CombatUnitCost >= 0:
		resources-=CombatUnitCost
		units.append(unit)
	
	if unit.name.substr(0,"Building".length()) == "Building" and "Building" in unlocked_units and resources - BuildingCost >= 0:
		resources-=BuildingCost
		units.append(unit)
		_unlock_combat_units()
	
func add_resource(value: int):
	resources+=value
# Funkcja odblokowująca jednostki bojowe
func _unlock_combat_units():
	if "CombatUnit"  not in unlocked_units:
		unlocked_units.append("CombatUnit")
		print("Combat units unlocked!")

func _unlock_building():
	if "Building"  not in unlocked_units:
		unlocked_units.append("Building")
		print("Building unlocked!")
