extends CanvasLayer


signal updatehp

@onready var game_over: Control = $Control/GameOver
@onready var continue_button: Button = $Control/GameOver/VBoxContainer/ContinueButton
@onready var exit_button: Button = $Control/GameOver/VBoxContainer/ExitButton
@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer
@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var label_2: Label = $Control/HBoxContainer/Label2
@onready var game_over_label: Label = $Control/GameOver/GameOverLabel



func _ready() -> void:
	await Player
	label_2.text = str(PlayerManager.player.stats.health)
	game_over_label.visible = false
	updatehp.connect ( update_hp )
	hide_game_over_screen()
	continue_button.pressed.connect( continue_game )
	exit_button.pressed.connect( exit_screen )
	LevelManager.level_load_started.connect( hide_game_over_screen )
	pass


func start_game() -> void:
	#play_audio( button_press_audio )
	#LevelManager.load_new_level( START_LEVEL , "" , Vector2.ZERO)
	pass

func update_hp() -> void:
	if PlayerManager.player.stats.health == 0:
		game_over_label.visible = true
		show_game_over_screen()
	label_2.text = str(PlayerManager.player.stats.health)

#func load_game() -> void:
	#await fade_to_black()

func continue_game() -> void:
	PlayerManager.player.relife()
	hide_game_over_screen()

func exit_screen() -> void:
	PlayerManager.player.visible = true
	
	PlayerHud.visible = true
	#PauseMenu.process_mode = Control.MOUSE_FILTER_STOP
	
	self.queue_free()
	get_tree().quit()

func show_game_over_screen() -> void:
	get_tree().paused = true
	game_over.visible = true
	game_over.mouse_filter = Control.MOUSE_FILTER_STOP
	game_over.modulate = Color(1,1,1,1)
	#continue_button.visible = can_continue
	
	#animation_player.play("show_game_over")
	#await  animation_player.animation_finished
	
	#if can_continue== true:
		#continue_button.grab_focus()
	#else:
		#title_button.grab_focus()
	
	pass

#func fade_to_black() -> bool:
	#animation_player.play("fade_to_black")
	#await animation_player.animation_finished
	#PlayerManager.player.revive_player()
	#return true
	#pass

func hide_game_over_screen() -> void:
	get_tree().paused = false
	game_over.visible = false
	game_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over.modulate = Color(1,1,1,0)


func play_audio( _a : AudioStream ) -> void:
	audio.stream = _a
	audio.play()
