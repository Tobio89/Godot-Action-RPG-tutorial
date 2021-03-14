extends Node2D

onready var animSprite = $AnimatedSprite

func _ready():
	animSprite.frame = 0
	animSprite.play("GrassDeath")


func _on_AnimatedSprite_animation_finished():
	queue_free()
