extends TileMapLayer

func get_tile_id(coordinates: Vector2) -> int:
	var tile_position = local_to_map(coordinates)
	var cell_id = get_cell_source_id(tile_position)
	return cell_id
