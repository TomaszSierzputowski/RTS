# GameSession.gd
extends Node

# Gracze w sesji
var player_1 : Player
var player_2 : Player

# Mapa gry
var map_scene = preload("res://Server/Game/test5/map.tscn")
var map_instance : Node = null

# Stan gry
var is_running : bool = false

# Funkcja inicjalizująca sesję gry
func start_session(player_1_scene: PackedScene, player_2_scene: PackedScene):
	# Wczytaj mapę
	map_instance = map_scene.instantiate()
	add_child(map_instance)


	# Uruchom sesję
	is_running = true

# Funkcja aktualizująca logikę sesji
func _process(delta):
	if is_running:
		# Tutaj można dodać logikę sesji, np. sprawdzanie zwycięzcy
		pass

# Zatrzymanie gry
func end_session():
	is_running = false
	if map_instance:
		map_instance.queue_free()
	if player_1:
		player_1.queue_free()
	if player_2:
		player_2.queue_free()
