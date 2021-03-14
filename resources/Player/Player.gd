extends KinematicBody2D

const MAX_SPEED = 100
const ACCEL = 500
const FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE

var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
	
func _ready():
	animationTree.active = true	
	
func _process(delta):
	
	match state:
		MOVE:
			movement(delta)
		ROLL:
			pass
		ATTACK:
			attacking(delta)


func movement(delta):

	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	input_vector = input_vector.normalized()
	
	if input_vector != 	Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCEL * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	velocity = move_and_slide(velocity)
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK


func attacking(delta):
	animationState.travel("Attack")
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION/2 * delta)
	velocity = move_and_slide(velocity)
	
func end_attack():
	state = MOVE
	