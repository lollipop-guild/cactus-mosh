extends "res://MoshEntity/Vehicle.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var default_flock

var fruit_scenes = [
	"res://Fruit/Apple.tscn",
	"res://Fruit/Orange.tscn",
	"res://Fruit/Pear.tscn"
]
var playback
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect('timeout', self, 'set_default_flock')
	default_flock = flock_type
	set_random_scene()
	playback = $art/AnimationTree.get("parameters/playback")
	playback.start("Idle")
	self.connect("body_entered", self, "_on_Mosher_body_entered")

func set_default_flock():
	flock_type = default_flock

func set_random_scene():
	var rand_int = randi() % fruit_scenes.size()
	var scene = load(fruit_scenes[rand_int])
	var temp = scene.instance()
	temp.name = "art"
	add_child(temp)

func _process(delta):
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group('bouncers'):
			transition_to_idle()
	if not flock_type & STATE.idle and not is_in_group('moshers'):
		add_to_group('moshers')
		playback.travel("Mosh")

func transition_to_idle():
	if flock_type != default_flock:
		print("transition to idle")
		remove_from_group('moshers')
		playback.travel("Idle")
		flock_type = 0
		$Timer.start()
