extends RefCounted

class_name Player

# Lista jednostek gracza
var Base: BaseBuilding1
var units: Array = []
var next_id = 0
var resources: int = 1000000

var BaseBuildingCost: int = 500
var MineCost: int = 100
var FastUnitFacotryCost: int = 100
var StandardUnitFacotryCost: int = 100
var HeavyUnitFacotryCost: int = 100
var WorkerUnitCost: int = 25
var FastUnitCost: int = 25
var StandardUnitCost: int = 25
var HeavyUnitCost: int = 25


# Lista odblokowanych jednostek
var unlocked_units: Array = ["Base"] 
var has_base: bool = false

func _init() -> void:
	units.resize(256)

# Funkcja dodająca jednostkę do gracza
func add_unit(unit: Node) -> int:
	if unit.has_method("get_class_name"):
		var classname = unit.get_class_name()
		match classname:
			"Base":
				if resources >= BaseBuildingCost and classname in unlocked_units:
					resources -= BaseBuildingCost
					has_base = true
					#units.append(unit)
					units[next_id] = unit
					next_id += 1
					_unlock_mine()
					_unlock_worker_units()
			"Mine":
				if resources >= MineCost and classname in unlocked_units:
					resources -= MineCost
					#units.append(unit)
					units[next_id] = unit
					next_id += 1
					_unlock_fast_unit_factory()
					_unlock_standard_unit_factory()
					_unlock_heavy_unit_factory()
							
			"HeavyUnitFactory":
				if resources >= HeavyUnitFacotryCost and classname in unlocked_units :
					resources -= HeavyUnitFacotryCost
					#units.append(unit)
					units[next_id] = unit
					next_id += 1
					_unlock_heavy_units()
			"FastUnitFactory":
				if resources >= FastUnitFacotryCost and classname in unlocked_units:
					resources -= FastUnitFacotryCost
					#units.append(unit)
					units[next_id] = unit
					next_id += 1
					_unlock_fast_units()
			"StandardUnitFactory":
				if resources >= StandardUnitFacotryCost and classname in unlocked_units:
					resources -= StandardUnitFacotryCost
					#units.append(unit)
					units[next_id] = unit
					next_id += 1
					_unlock_standard_units()
			"WorkerUnit":
				if resources >= WorkerUnitCost and classname in unlocked_units:
					resources -= WorkerUnitCost
					#units.append(unit)
					units[next_id] = unit
					next_id += 1
			"FastUnit":
				if resources >= FastUnitCost and classname in unlocked_units:
					resources -= FastUnitCost
					#units.append(unit)
					units[next_id] = unit
					next_id += 1
			"StandardUnit":
				if resources >= StandardUnitCost and classname in unlocked_units:
					resources -= StandardUnitCost
					#units.append(unit)
					units[next_id] = unit
					next_id += 1
			"HeavyUnit":
				if resources >= HeavyUnitCost and classname in unlocked_units:
					resources -= HeavyUnitCost
					#units.append(unit)
					units[next_id] = unit
					next_id += 1
		return next_id - 1
	else:
		return -1
	
		
func add_resource(value: int):
	if value >= 0:
		resources+=value
		
func _unlock_mine():
	if "Mine" not in unlocked_units:
		unlocked_units.append("Mine")
		print("Mines unlocked!")


func _unlock_worker_units():
	if "WorkerUnit"  not in unlocked_units:
		unlocked_units.append("WorkerUnit")
		print("Worker units unlocked!")
		
func _unlock_fast_units():
	if "FastUnit"  not in unlocked_units:
		unlocked_units.append("FastUnit")
		print("Fast unit unlocked!")

func _unlock_standard_units():
	if "StandardUnit"  not in unlocked_units:
		unlocked_units.append("StandardUnit")
		print("Standard unit unlocked!")

func _unlock_heavy_units():
	if "HeavyUnit"  not in unlocked_units:
		unlocked_units.append("HeavyUnit")
		print("Heavy unit unlocked!")

func _unlock_fast_unit_factory():
	if "FastUnitFactory" not in unlocked_units:
		unlocked_units.append("FastUnitFactory")
		print("Fast unit factory unlocked!")

func _unlock_standard_unit_factory():
	if "StandardUnitFactory" not in unlocked_units:
		unlocked_units.append("StandardUnitFactory")
		print("Standard unit factory unlocked!")	
		
func _unlock_heavy_unit_factory():
	if "HeavyUnitFactory" not in unlocked_units:
		unlocked_units.append("HeavyUnitFactory")
		print("Heavy unit factory unlocked!")
