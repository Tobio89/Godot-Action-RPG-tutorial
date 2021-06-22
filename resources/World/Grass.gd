extends Node2D


const GrassEffect = preload("res://Resources/Effects/GrassEffect.tscn")

func doGrassEffect():

	var grassEffectInst = GrassEffect.instance()
	grassEffectInst.global_position = global_position
	var grassesNode = get_parent().add_child(grassEffectInst)

func _on_Hurtbox_area_entered(area):
	
	doGrassEffect()
	queue_free()
