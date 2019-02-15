extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var WALK_MAX_VELOCITY = 150
export var WALK_ACCEL = 400
export var WALK_DEACCEL = 300
var dashing = false
export var dash_speed = 80
var dash_time = 2
export var dash_length = 5
export var mosh_weight = 5
export var not_mosh_penalty = 3
var time_since_dance = -1
onready var global = get_node('/root/global')
var playback
var facing_left = false
var original_art_scale
var anim = ""
var knockdown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect('timeout', self, 'add_percent')
	playback = $Art/AnimationTree.get("parameters/playback")
	playback.start("Idle")
	original_art_scale = $Art.scale
	
func add_percent():
	var mosh_weight = calculate_mosh_weight()
	if linear_velocity.length() < WALK_MAX_VELOCITY+20 and mosh_weight > 0:
		global.percent_complete += mosh_weight
		trigger_particles()
		time_since_dance = 10
	elif time_since_dance < 0 and global.percent_complete > 0:
		global.percent_complete -= max(not_mosh_penalty, 0)
	else:
		time_since_dance -= 1

func calculate_mosh_weight():
	var bodies = $Area2D.get_overlapping_bodies()
	var weight = 0
	for body in bodies:
		if body.is_in_group('moshers'):
			weight += body.mosh_weight
	return weight

func trigger_particles():
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group('moshers'):
			body.trigger_particle()
			
func knockdown():
	knockdown = true
	playback.start("Knockdown")

func _integrate_forces(state):
	var move_left = Input.is_action_pressed("walk_left")
	var move_right = Input.is_action_pressed("walk_right")
	var move_up = Input.is_action_pressed("walk_up")
	var move_down = Input.is_action_pressed("walk_down")
	var dash = Input.is_action_pressed("dash")
	var lv = state.get_linear_velocity()
	var step = state.step
	var delta_velocity = Vector2(0, 0)
	var new_facing_left = facing_left
	var new_anim
	
	if not knockdown:
		## Movement left and right
		if move_left and not move_right:
			delta_velocity.x -= WALK_ACCEL * step
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= WALK_ACCEL * step
		elif move_right and not move_left:
			delta_velocity.x += WALK_ACCEL * step
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += WALK_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= WALK_DEACCEL * step
			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv
			
		# Handle up an down
		if move_up and not move_down:
			delta_velocity.y -= WALK_ACCEL * step
			if lv.y > -WALK_MAX_VELOCITY:
				lv.y -= WALK_ACCEL * step
		elif move_down and not move_up:
			delta_velocity.y += WALK_ACCEL * step
			if lv.y < WALK_MAX_VELOCITY:
				lv.y += WALK_ACCEL * step
		else:
			var yv = abs(lv.y)
			yv -= WALK_DEACCEL * step
			if yv < 0:
				yv = 0
			lv.y = sign(lv.y) * yv
	
		if dash and not dashing:
			dash_time += step
			lv *= dash_speed
			dashing = true
			if (delta_velocity.length() > 0):
				state.set_linear_velocity(delta_velocity * dash_speed)
		else:
			if lv.length() > WALK_MAX_VELOCITY and not dashing:
				lv = lv.normalized()*WALK_MAX_VELOCITY
			state.set_linear_velocity(lv)
			
		if dashing:
			dash_time += state.step
			if dash_time > dash_length:
				dash_time = 0
				dashing = false

	# Animations & Scaling
	if lv.x < 0 and move_left:
		new_facing_left = true
	elif lv.x > 0 and move_right:
		new_facing_left = false

	if new_facing_left != facing_left:
		var new_scale
		if new_facing_left:
			new_scale = original_art_scale.x * -1
			$Art.scale = Vector2(new_scale, original_art_scale.y)
		else:
			$Art.scale.x = original_art_scale.x
		
		facing_left = new_facing_left
	
	if dashing:
		new_anim = "Dash"
	elif time_since_dance > 0:
		new_anim = "Mosh"
	else:
		if abs(lv.x) < 0.1 && abs(lv.y) < 0.1:
			new_anim = "Idle"
		else:
			new_anim = "Walk"
	
	if new_anim != anim:
		anim = new_anim
		playback.start(anim)