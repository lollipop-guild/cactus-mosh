extends "res://MoshEntity/Vehicle.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var default_flock
var sprites = [
	preload("res://Fruit/Textures/AppleRef.png"),
	preload("res://Fruit/Textures/PearRef.png"),
	preload("res://Fruit/Textures/OrangeRef.png")
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	set_random_sprite()
	$Timer.connect('timeout', self, 'set_default_flock')
	default_flock = flock_type

func set_default_flock():
	flock_type = default_flock

func set_random_sprite():
	var rand_int = randi() % sprites.size()
	$Position2D/Sprite.texture = sprites[rand_int]

func _process(delta):
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group('bouncer'):
			transition_to_idle()

func transition_to_idle():
	if flock_type != default_flock:
		flock_type = 0
		$Timer.start()