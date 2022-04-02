extends KinematicBody2D


var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

export (int) var ACCELERATION = 300
export (int) var MAX_SPEED = 50
export (int) var FRICTION = 200

export (float) var INVIN = 0.2

onready var anim = $BatAnimSprite
onready var batSprite = $BatAnimSprite
onready var hurtbox = $Hurtbox
onready var playerDetection = $PlayerDetectionZone
onready var softCollision = $SoftCollision
onready var stats = $Stats
onready var wanderController = $WanderController

const DeathEffect = preload("res://resources/Effects/EnemyDeath.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = IDLE

func _ready():
	randomize()
	anim.frame = rand_range(0, anim.frames.get_frame_count("Fly")-1)
	anim.play()
	
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			handle_wander_timer_elapsed()

		WANDER:
			seek_player()
			handle_wander_timer_elapsed()
			var direction = global_position.direction_to(wanderController.target_position)
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			
			if global_position.distance_to(wanderController.target_position) <= MAX_SPEED * delta:
				renew_wander_timer()
					
			
			
		CHASE:
			var player = playerDetection.player
			if player != null:
				var direction = global_position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)	
			else:
				state = IDLE
		
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 1000
	velocity = move_and_slide(velocity)	
	batSprite.flip_h = velocity.x < 0
	
func seek_player():
	if playerDetection.can_see_player():
		state = CHASE	

func handle_wander_timer_elapsed():
	if wanderController.get_time_left() == 0:
		renew_wander_timer()


func renew_wander_timer():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(2, 5))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	


func do_death_effect():
	var deathEffectInst = DeathEffect.instance()
	deathEffectInst.global_position = global_position
	var enemiesNode = get_parent().add_child(deathEffectInst)
	
func die():
	do_death_effect()
	queue_free()
	

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 160
	stats.health -= area.damage
	hurtbox.start_invincibility(INVIN)
	hurtbox.create_hit_effect()
	
	if stats.health > 0:
		print("Bat says, 'Ouch' ", stats.health)


func _on_Stats_no_health():
	print("Bat says, 'Aaaa'")
	die()
