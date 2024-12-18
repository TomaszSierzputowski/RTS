extends Node

var id: int
var characters: Array[Character]
var buildings: Array[Building]
var resources: Dictionary

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	pass

func _init(id: int) -> void:
	self.id = id
	self.characters = []
	self.buildings = []
	self.resources = {
		"Gold" : 100
	}
