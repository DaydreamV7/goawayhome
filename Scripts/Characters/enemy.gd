class_name Enemy
extends CharacterBody2D

enum Direction{
	LEFT = -1,
	RIGHT = 1,
}

enum State{
	IDLE,
	WALK,
	RUN,
	STUN,
	DYING,
}

signal enemy_dead

@export var direction := Direction.RIGHT:
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = direction
@export var max_speed: float = 180
@export var acceleration: float = 2000

const KNOCKBACK_AMOUNT := 512.0

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_hurt := false as bool

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var stats: Stats = $Stats
@onready var wall_check: RayCast2D = $Graphics/WallCheck
@onready var floor_check: RayCast2D = $Graphics/FloorCheck
@onready var calm_down_timer: Timer = $CalmDownTimer
@onready var player_check: RayCast2D = $Graphics/PlayerCheck
@onready var hitbox: HitBox = $Graphics/Hitbox
@onready var hp_number: Label = $Control/HPNumber


func _ready() -> void:
	hitbox.damaged.connect(_on_hitbox_damaged)
	hp_number.text = str(stats.max_health)
	
	
func can_see_player() -> bool:
	if not player_check.is_colliding():
		return false
	else:
		return player_check.get_collider() is Player

func move(speed: float,delta: float) -> void:
	velocity.x = move_toward(velocity.x,speed*direction, acceleration * delta)
	velocity.y += default_gravity * delta
	move_and_slide()
	
func die() -> void:
	queue_free()

func tick_physics(state:State,delta:float) -> void:
	match state:
		State.IDLE,State.STUN,State.DYING:
			move(0.0,delta)
		State.WALK:
			move(max_speed/3,delta)
		State.RUN:
			if wall_check.is_colliding() or not floor_check.is_colliding():
				direction *= -1
			move(max_speed,delta)
			if can_see_player():
				calm_down_timer.start()


func get_next_state(state : State) -> int:
	if stats.health == 0:
		return StateMachine.KEEP_CURRENT if state == State.DYING else State.DYING
	if is_hurt == true:
		return State.STUN
	match state:
		State.IDLE:
			if can_see_player():
				return State.RUN
			if state_machine.state_time > 2 :
				return State.WALK
		State.WALK:
			if can_see_player():
				return State.RUN
			if wall_check.is_colliding() or not floor_check.is_colliding():
				return State.IDLE
		State.RUN:
			if not can_see_player() and calm_down_timer.is_stopped() and is_on_floor():
				return State.WALK
		State.STUN:
			if not animation_player.is_playing():
				return State.RUN
		
	return StateMachine.KEEP_CURRENT
	
func transition_state(from: State,to: State) -> void:
	#print("[%s] %s => %s" % [
		#Engine.get_physics_frames(),
		#State.keys()[from] if from != -1 else "<START>",
		#State.keys()[to],
	#])
	
	match to:
		State.IDLE:
			animation_player.play("idle")
			if wall_check.is_colliding():
				direction *= -1
		State.WALK:
			animation_player.play("walk")
			if not floor_check.is_colliding():
				direction *= -1
				floor_check.force_raycast_update()
		State.RUN:
			animation_player.play("run")
		State.STUN:
			is_hurt = false
			hitbox.monitorable = false
			animation_player.play("stun")
			await animation_player.animation_finished
			hitbox.monitorable = true
		State.DYING:
			enemy_dead.emit()
			animation_player.play("die")
			await animation_player.animation_finished
			die()
			
func _on_hitbox_damaged(hurt_box: HurtBox) -> void:
	is_hurt = true
	stats.health -= hurt_box.damage
	hp_number.text = str(stats.health)
	var dir := hurt_box.global_position.direction_to(global_position)
	velocity = dir * KNOCKBACK_AMOUNT
	if dir.x >0:
		direction = Direction.LEFT
	else:
		direction = Direction.RIGHT
	pass
