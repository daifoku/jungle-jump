extends CharacterBody2D

signal life_changed(life: int)
signal died

@export var life: int = 3:
	set(value):
		life = value 
		life_changed.emit(life)
		if life <= 0:
			change_state(DEAD)

@export var gravity: float = 750
@export var run_speed: float = 150
@export var jump_speed: float = -300

enum {IDLE, RUN, JUMP, HURT, DEAD}
var state: int = IDLE

func _ready() -> void:
	change_state(IDLE)

func change_state(new_state: int) -> void:
	state = new_state
	match state:
		IDLE:
			$AnimationPlayer.play("idle")
		RUN:
			$AnimationPlayer.play("run")
		HURT:
			$AnimationPlayer.play("hurt")
			velocity.y = -200
			# Check if velocity.x is near zero, and if so, apply a small random horizontal bounce
			if abs(velocity.x) <= 10:
					velocity.x = randf_range(-1, 1) * 100 # Randomly set x to either -100 or 100
			else:
				velocity.x = -100 * sign(velocity.x) # Reverse direction if already moving horizontally
			life -= 1
			await get_tree().create_timer(0.5).timeout
			change_state(IDLE)
		JUMP:
			$AnimationPlayer.play("jump_up")
		DEAD:
			died.emit()
			hide()
		
func get_input() -> void:
	if state == HURT:
		return
		
	var right: bool = Input.is_action_pressed("right")
	var left: bool = Input.is_action_pressed("left")
	var jump: bool = Input.is_action_just_pressed("jump")
	
	# Movement occurs in all states
	velocity.x = 0
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite2D.flip_h = true
		
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed
		
	if state == IDLE and velocity.x != 0:
		change_state(RUN)
		
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
		
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)
	
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	# Process user input
	get_input()
	# Update the player
	move_and_slide()
	# Detect when a jump ends (move and slide's update to the is_on_floor)
	if state == JUMP and is_on_floor():
		change_state(IDLE)
	# Check if the character is "falling"
	if state == JUMP and velocity.y > 0:
		$AnimationPlayer.play("jump_down")
		
func reset(_position: Vector2) -> void:
	position = _position
	show()
	change_state(IDLE)
	life = 3
	
func hurt() -> void:
	if state != HURT:
		change_state(HURT)
		
