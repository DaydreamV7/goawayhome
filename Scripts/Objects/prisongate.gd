class_name PrisonGate
extends Node2D

@export var next_scece : Node2D

var mount : int = 0


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D
@onready var label: Label = $Label

func _ready() -> void:
	area_2d.area_entered.connect( _on_area_enter )
	area_2d.monitoring = false
	for i in get_parent().get_children():
		if i is Enemy:
			i.enemy_dead.connect(dead_amount)
			mount += 1
	label.visible = false
	#area_2d.monitoring = false
	


func dead_amount() -> void:
	if mount == 1:
		animation_player.play("open")
		area_2d.monitoring = true
	mount -= 1

#func _on_area_enter( _a : Area2D ) -> void:
	
	
func _on_area_enter( _a : Area2D ) -> void:
	PlayerManager.interact_pressed.connect( player_interact )
	label.visible = true
	pass
	
	
func _on_area_exit( _a : Area2D ) -> void:
	PlayerManager.interact_pressed.disconnect( player_interact )
	pass

func player_interact() -> void:
	print("interact")
	pass
