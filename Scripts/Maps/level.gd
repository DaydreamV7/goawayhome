class_name Level
extends Node2D

@export var music : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.set_as_parent( self )
	#PlayerManager.player.direction = Vector2.ZERO
	LevelManager.level_load_started.connect( _free_level )
	#AudioManager.play_music(music)
	pass

func _free_level() -> void:
	PlayerManager.unparent_player(self)
	queue_free()
