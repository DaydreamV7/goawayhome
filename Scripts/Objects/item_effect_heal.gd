class_name ItemEffectHeal extends ItemEffect

@export var heal_mount : int = 1
@export var audio : AudioStream

func use() -> void:
	pass
	#PlayerManager.player.update_hp( heal_mount )
	#PauseMenu.play_audio( audio )
