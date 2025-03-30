class_name LevelTileMap extends TileMapLayer

@export var tile_size : float = 16


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelManager.ChangeTilemapBounds( GetTilemapBounds() )
	pass # Replace with function body.


func GetTilemapBounds() -> Array[ Vector2 ]:
	var bounds : Array[ Vector2 ] = []
	bounds.append(
		Vector2( get_used_rect().position * tile_size ) + position
	)
	bounds.append(
		Vector2( get_used_rect().end * tile_size ) + position - Vector2(16,0) #手动修复bug
	)
	return bounds
