class_name Transmit
extends Area2D

@export var next_teleport : Wardrobe


var exist_timer : float = 15.0

@onready var transmit_area: Area2D = $TransmitArea

func _ready() -> void:
	area_entered.connect( _on_area_enter )
	area_exited.connect( _on_area_exit )
	pass



func _on_area_enter() -> void:
	print("OK")
	PlayerManager.interact_pressed.connect( player_interact )
	pass
	
	
func _on_area_exit() -> void:
	PlayerManager.interact_pressed.disconnect( player_interact )
	pass

func player_interact() -> void:
	print(PlayerManager.player.global_position)
	print(" -> ")
	print(next_teleport.global_position)
	PlayerManager.player.global_position = next_teleport.global_position
	pass
