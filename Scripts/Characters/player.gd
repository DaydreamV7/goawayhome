class_name Player
extends CharacterBody2D

enum State{
	IDLE,
	RUNNING,
	JUMP,
	STUN,
	DYING,
	ATTACK
}


var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false as bool
var is_hurt := false as bool

const GROUND_STATES := [
	State.IDLE,State.RUNNING
]
const Speed := 160.0
const Jump := -320
const Floor_Acceleration := Speed / 0.2
const Air_Acceleration := Speed / 0.1

@onready var graphics: Node2D = $Graphics
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer
@onready var state_machine: StateMachine = $StateMachine
@onready var stats: Stats = $Stats
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: HitBox = $Graphics/Hitbox

func _ready() -> void:
	hitbox.damaged.connect(_on_hitbox_damaged)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
		velocity.y = -400 #Test
		pass
	if event.is_action_released("jump"):
		if velocity.y < Jump / 2.0:
			velocity.y = Jump / 2.0
	
	if event.is_action_pressed("interacter"):
		PlayerManager.interact_pressed.emit()
	if event.is_action_pressed("pause"):
		PlayerHud.show_game_over_screen()
	
	
	if event.is_action_pressed("test"):
		stats.health -= 1
		PlayerHud.updatehp.emit()

func stand(gravity:float , delta: float) -> void:
	var acceleration := Floor_Acceleration if is_on_floor() else Air_Acceleration
	velocity.x = move_toward(velocity.x,0.0, acceleration * delta)
	velocity.y += gravity * delta
	move_and_slide()

func move(gravity:float,delta:float) -> void:	
	var direction := Input.get_axis("move_left","move_right")
	var acceleration := Floor_Acceleration if is_on_floor() else Air_Acceleration
	velocity.x = move_toward(velocity.x,direction * Speed, acceleration * delta)
	velocity.y += gravity * delta
	
	if not is_zero_approx(direction):
		graphics.scale.x = -1 if direction < 0 else +1
	
	move_and_slide()


func tick_physics(state:State,delta: float) -> void:
	match state:
		State.IDLE:
			move(default_gravity,delta)
		State.RUNNING:
			move(default_gravity,delta)
		State.JUMP:
			move(0.0 if is_first_tick else default_gravity,delta)
		State.STUN:
			move(default_gravity,delta)
		State.DYING:
			stand(default_gravity,delta)
		State.ATTACK:
			stand(default_gravity,delta)
	is_first_tick = false
	pass
	
func get_next_state(state:State) -> int:
	if stats.health == 0:
		return StateMachine.KEEP_CURRENT if state == State.DYING else State.DYING
	if is_hurt == true:
		return State.STUN
	var can_jump := is_on_floor() or coyote_timer.time_left > 0
	var should_jump := can_jump and jump_request_timer.time_left > 0
	if should_jump:
		return State.JUMP
	var direction := Input.get_axis("move_left","move_right")
	var is_still := is_zero_approx(direction) and is_zero_approx(velocity.x)
	match state:
		State.IDLE:
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK
			if not is_still:
				return State.RUNNING
		State.RUNNING:
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK
			if is_still:
				return State.IDLE
		State.JUMP:
			if is_on_floor():
				return State.IDLE
		State.STUN:
			if not animation_player.is_playing():
				hitbox.monitorable = true
				return State.IDLE
		State.ATTACK:
			if not animation_player.is_playing():
				return State.IDLE
	return StateMachine.KEEP_CURRENT
	pass
	
func transition_state(from: State,to: State) -> void:
	#print("[%s] %s => %s" % [
		#Engine.get_physics_frames(),
		#State.keys()[from] if from != -1 else "<START>",
		#State.keys()[to],
	#])
	
	if from not in GROUND_STATES and to in GROUND_STATES:
		coyote_timer.stop()
	match to:
		State.IDLE:
			animation_player.play("idle")
		State.RUNNING:
			animation_player.play("running")
		State.JUMP:
			animation_player.play("jump")
			velocity.y = Jump
			coyote_timer.stop()
			jump_request_timer.stop()
		State.STUN:
			is_hurt = false
			hitbox.monitorable = false
			animation_player.play("stun")
			await animation_player.animation_finished
			hitbox.monitorable = true
		State.DYING:
			animation_player.play("die")
		State.ATTACK:
			animation_player.play("attack")
	is_first_tick = true
	pass
#
#
func _on_hitbox_damaged(hurt_box: HurtBox) -> void:
	PlayerHud.updatehp.emit()
	is_hurt = true
	stats.health -= hurt_box.damage
	var dir := hurt_box.global_position.direction_to(global_position)
	velocity = dir * 400
	velocity.y = -300
	pass
