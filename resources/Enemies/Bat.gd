extends KinematicBody2D


var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

export (int) var ACCELERATION = 300
export (int) var MAX_SPEED = 50
export (int) var FRICTION = 200

onready var stats = $Stats
onready var anim = $BatAnimSprite
onready var playerDetection = $PlayerDetectionZone

const DeathEffect = preload("res://resources/Effects/EnemyDeath.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = IDLE

func _ready():
	anim.play()
	print(stats.health)
	
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			
		WANDER:
			pass
		CHASE:
			pass
	
func seek_player():
	if playerDetection.can_see_player():
		state = CHASE	
	
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
	if stats.health > 0:
		print("Bat says, 'Ouch'", stats.health)


func _on_Stats_no_health():
	print("Bat says, 'Aaaa'")
	die()
