class_name TitleScene
extends Node2D

const START_SCECE : String = "res://Scenes/Maps/room.tscn"

@onready var wardrobe: Wardrobe = $Wardrobe
@onready var button_start: Button = $CanvasLayer/Control/ButtonStart


func _ready() -> void:
	wardrobe.label.visible = false
	get_tree().paused = true
	PlayerManager.player.visible = false
	
	#PlayerHud.visible = false
	#PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
	
	button_start.pressed.connect( startgame )
	pass


func startgame() -> void:
	print("被按下")
	get_tree().change_scene_to_file( START_SCECE )
	#PlayerManager.unparent_player(self)
	#queue_free()
