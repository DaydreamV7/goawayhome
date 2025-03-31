class_name HurtBox extends Area2D

signal did_damage

@export var damage : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect( hit_entered )
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func change_damage() -> void:
	damage = 3

func hit_entered( a : Area2D ) -> void:
	if a is HitBox:
		did_damage.emit()
		a.takedamage( self )
	pass
