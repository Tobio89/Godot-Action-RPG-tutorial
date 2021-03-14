extends Node2D


func doGrassEffect():

	var GrassEffect = load("res://Resources/Effects/GrassEffect.tscn")
	var grassEffectInst = GrassEffect.instance()
	grassEffectInst.global_position = global_position
	var grassesNode = get_tree().get_root().get_node("World/YSort/Grasses").add_child(grassEffectInst)

func _on_Hurtbox_area_entered(area):
	
	doGrassEffect()
	queue_free()
