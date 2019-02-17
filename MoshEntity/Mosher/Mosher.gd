extends "res://MoshEntity/Vehicle.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var default_flock

var playback
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect('timeout', self, 'set_default_flock')
	default_flock = flock_type
	playback = $art/AnimationTree.get("parameters/playback")
	playback.start("Dance")

func set_default_flock():
	flock_type = default_flock

func _process(delta):
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group('bouncers'):
			transition_to_idle()
	if not flock_type & STATE.idle and not is_in_group('moshers'):
		add_to_group('moshers')
		playback.start("Mosh")
	$CollisionPolygon2D.set_transform($art/Body.get_transform())
	$CollisionPolygon2D.global_position = $art/Body.global_position

func trigger_particle():
	$CPUParticles2D.emitting = true
	$CPUParticles2D.restart()

func transition_to_idle():
	if flock_type != default_flock:
		if is_in_group('moshers'):
			remove_from_group('moshers')
		playback.start("Dance")
		flock_type = STATE.idle
		$Timer.start()
