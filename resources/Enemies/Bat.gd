extends KinematicBody2D


var knockback = Vector2.ZERO

onready var stats = $Stats
onready var anim = $BatAnimSprite
func _ready():
	anim.play()
	print(stats.health)
	
func die():
	queue_free()

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200*delta)
	knockback = move_and_slide(knockback)

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 160
	stats.health -= area.damage
	
	print("Bat says, 'ouch'", stats.health)


func _on_Stats_no_health():
	print("Bat says, 'Aaaa'")
	die()
