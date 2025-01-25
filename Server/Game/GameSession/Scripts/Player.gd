extends Node

class_name Player

# Lista jednostek gracza
var Base: BaseBuilding
var units: Array = []
var resources: int = 1000000

var BaseBuildingCost: int = 500
var FastUnitFacotryCost: int = 100
var StandardUnitFacotryCost: int = 100
var HeavyUnitFacotryCost: int = 100
var WorkerUnitCost: int = 25
var CombatUnitCost: int = 50
var BuildingCost: int = 100

# Lista odblokowanych jednostek
var unlocked_units: Array = ["BaseBuilding"]  

# Funkcja dodająca jednostkę do gracza
func add_unit(unit: Node):
	units.append(unit)
	return
	
	if unit.name.substr(0,"BaseBuilding".length()) == "BaseBuilding" and "BaseBuilding" in unlocked_units and resources - BaseBuildingCost >= 0:
		resources -= BaseBuildingCost
		units.append(unit)
		_unlock_worker_units()
	
	if unit.name.substr(0,"WorkerUnit".length()) == "WorkerUnit" and "WorkerUnit" in unlocked_units and resources - WorkerUnitCost >= 0:
		resources-=WorkerUnitCost
		units.append(unit)
		_unlock_building()
	
	if unit.name.substr(0,"FastUnitFacotry".length()) == "FastUnitFactory" and "FastUnitFactory" in unlocked_units and resources - FastUnitFacotryCost >= 0:
		resources -= FastUnitFacotryCost
		units.append(unit)
		_unlock_combat_units()
	
	if unit.name.substr(0,"StandardUnitFacotry".length()) == "StandardUnitFactory" and "StandardUnitFactory" in unlocked_units and resources - FastUnitFacotryCost >= 0:
		resources -= FastUnitFacotryCost
		units.append(unit)
		_unlock_combat_units()
		
	if unit.name.substr(0,"HeavyUnitFacotry".length()) == "HeavyUnitFactory" and "HeavyUnitFactory" in unlocked_units and resources - FastUnitFacotryCost >= 0:
		resources -= FastUnitFacotryCost
		units.append(unit)
		_unlock_combat_units()
	
	if unit.name.substr(0,"CombatUnit".length()) == "CombatUnit" and "CombatUnit" in unlocked_units and resources - CombatUnitCost >= 0:
		resources-=CombatUnitCost
		units.append(unit)
	
	
		
func add_resource(value: int):
	if value >= 0:
		resources+=value

func _unlock_worker_units():
	if "WorkerUnit"  not in unlocked_units:
		unlocked_units.append("WorkerUnit")
		print("Worker units unlocked!")

func _unlock_combat_units():
	if "CombatUnit"  not in unlocked_units:
		unlocked_units.append("CombatUnit")
		print("Combat units unlocked!")

func _unlock_building():
	if "FastUnitFactory"  not in unlocked_units:
		unlocked_units.append("FastUnitFactory")
	if "StandardUnitFactory"  not in unlocked_units:
		unlocked_units.append("StandardUnitFactory")
	if "HeavyUnitFactory"  not in unlocked_units:
		unlocked_units.append("HeavyUnitFactory")
	print("Building unlocked!")
