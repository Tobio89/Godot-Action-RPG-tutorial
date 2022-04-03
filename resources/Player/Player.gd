extends KinematicBody2D

const PlayerHurtSound = preload("res://resources/Player/PlayerHurtSound.tscn")

export (int) var MAX_SPEED = 100
export (int) var ROLL_SPEED = 160
export (int) var ACCEL = 500
export (int) var FRICTION = 500

export (float) var INVINCIBILITY_DURATION = 0.5
export (bool) var HAMMER_TIME = false

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE

var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var hitFlashPlayer = $HitFlashPlayer
onready var hurtbox = $Hurtbox
onready var swordHitbox = $HitboxPivot/SwordHitbox

	
func _ready():
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true	
	swordHitbox.knockback_vector = roll_vector
	
func _physics_process(delta):
	
	match state:
		MOVE:
			movement(delta)
		ROLL:
			rolling(delta)
		ATTACK:
			attacking(delta)


func movement(delta):

	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	input_vector = input_vector.normalized()
	
	
	if input_vector != 	Vector2.ZERO:
		roll_vector = input_vector
		
		swordHitbox.knockback_vector = input_vector
		
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCEL * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
	if Input.is_action_just_pressed("roll"):
		if input_vector != Vector2.ZERO:
			state = ROLL


func move():
	velocity = move_and_slide(velocity)

func rolling(_delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attacking(delta):
	animationState.travel("Attack")
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION/2 * delta)
	move()
	
func end_attack():
	state = MOVE
	
func end_roll():
	state = MOVE


func _on_Hurtbox_area_entered(area):
	if !HAMMER_TIME:
		hurtbox.start_invincibility(INVINCIBILITY_DURATION)
		hurtbox.create_hit_effect()
		stats.health -= area.damage
		var playerHurtSound = PlayerHurtSound.instance()
		get_tree().current_scene.add_child(playerHurtSound)
		


func _on_Hurtbox_invincibility_started():
	hitFlashPlayer.play("Flash")


func _on_Hurtbox_invincibility_ended():
	hitFlashPlayer.play("Stop")
