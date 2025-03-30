class_name Wardrobe
extends Node2D

@export var next_teleport : Wardrobe


var exist_timer : float = 15.0

@onready var transmit_area: Area2D = $TransmitArea
@onready var label: Label = $Label


func _ready() -> void:
	transmit_area.area_entered.connect( _on_area_enter )
	transmit_area.area_exited.connect( _on_area_exit )
	pass

func _physics_process(delta: float) -> void:
	if transmit_area.monitoring == false:
		exist_timer -= delta
		label.text = "%.1f" % exist_timer
	if exist_timer <= 0:
		label.text = "E"
		transmit_area.monitoring = true
		exist_timer = 15.0

func _on_area_enter( _a : Area2D ) -> void:
	PlayerManager.interact_pressed.connect( player_interact )
	pass
	
	
func _on_area_exit( _a : Area2D ) -> void:
	PlayerManager.interact_pressed.disconnect( player_interact )
	pass

func player_interact() -> void:
	if transmit_area.monitoring == true:
		PlayerManager.player.global_position = next_teleport.global_position
		transmit_area.monitoring = false
	pass
