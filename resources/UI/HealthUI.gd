extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty


func set_hearts(val):
	hearts = clamp(val, 0, max_hearts)
	set_heart_full_rect(hearts)
	
func set_max_hearts(val):
	max_hearts = max(val, 1)
	self.hearts = min(hearts, max_hearts)
	set_heart_empty_rect(max_hearts)

func set_heart_full_rect(val):
	if heartUIFull != null:
		heartUIFull.rect_size.x = val * 15

func set_heart_empty_rect(val):
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = val * 15



func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
