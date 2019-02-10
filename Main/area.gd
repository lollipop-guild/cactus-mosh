extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var area_size = Vector2(32, 32)
# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.shape.extents = area_size
	$ColorRect.rect_size = area_size*2
	$ColorRect.rect_position = -area_size

func highlight():
	$ColorRect.show()

func remove_highlight():
	$ColorRect.hide()