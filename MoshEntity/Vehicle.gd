extends "res://MoshEntity/flock.gd"

var heading = Vector2(0, 1)
var velocity = Vector2(0, 0)
var side
export var min_velocity = Vector2(10, 10)
export var seek_flee_multiplier = 2.0
export var mosh_weight = 1
export var debug_text = false

enum STATE {
	seek = 1,
	flee = 2,
	pursuit = 4,
	evade = 8,
	wander = 16,
	wall_avoid = 32,
	idle = 64
}

func _ready():
	RayRight = $Position2D/RayRight
	RayLeft  = $Position2D/RayLeft
	RayRight.add_exception(self)
	RayLeft.add_exception(self)
	wander_target = self.position
	target = get_node(target)
	if debug_text:
		$DebugLabel.show()

var steering_force = Vector2(0, 0)

func _draw():
	if debug_text:
		draw_line(Vector2(0, 0), heading, Color(0, 1, 1))

func set_target(target):
	self.target = target

func _process(delta):
	display_debug_text()

func display_debug_text():
	$DebugLabel.text = str(flock_type)

func _integrate_forces(state):
	#f=ma -> a=f/a
	rotation = 0
	var target_pos = get_parent().to_local(target.position)
	var new_ray_length = calc_ray_length()
	RayLeft.cast_to = new_ray_length
	RayRight.cast_to = new_ray_length
	steering_force = Vector2(0, 0)
	if linear_velocity.length() > min_velocity.length() and flock_type & STATE.idle:
		#TODO: Move to function
		set_collision_mask_bit(2, true)
		set_collision_layer_bit(2, true)
		flock_type = flock_type ^ STATE.idle
	if (flock_type & STATE.seek):
		steering_force += seek(target_pos, self)
		steering_force *= seek_flee_multiplier
	if (flock_type & STATE.flee):
		steering_force += flee(target_pos, self)
		steering_force *= seek_flee_multiplier
	if (flock_type & STATE.pursuit):
		steering_force = pursuit(target, self)
	if (flock_type & STATE.evade):
		steering_force = evade(target_pos, self)
	if (flock_type & STATE.wander):
		steering_force += wander()
	if (flock_type & STATE.wall_avoid):
		var potential_avoid = self.wall_avoid()
		if (potential_avoid.length() > 0):
			steering_force += potential_avoid
	if (flock_type & STATE.idle):
		set_collision_mask_bit(2, false)
		set_collision_layer_bit(2, false)
		steering_force = Vector2(0, 0)
		state.set_linear_velocity(Vector2(0,0))
	
	var acceleration = steering_force / self.mass
	velocity  += acceleration * state.step
	#Need to figure out a way to truncate a vector
	if velocity.length() > MAX_SPEED:
		 velocity = velocity.normalized()*MAX_SPEED
	#position += velocity * time_elapsed
	
	#Update the heading
	if velocity.length_squared() > .00000001:
		heading = lerp(heading, velocity, MAX_TURN_RATE)
		$Position2D.look_at(position+heading)
		$Position2D.rotate(PI/2)
		#Need to calc the perp
	velocity += state.get_total_gravity() * state.step
	state.set_linear_velocity(velocity)
	update()
	

