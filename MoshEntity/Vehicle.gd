extends "res://MoshEntity/flock.gd"

var heading = Vector2(0, 1)
var velocity = Vector2(0, 0)
var side

func _ready():
	RayRight = $Position2D/RayRight
	RayLeft  = $Position2D/RayLeft
	RayRight.add_exception(self)
	RayLeft.add_exception(self)
	var children = get_parent().get_children()
	var rand_int = randi() % children.size()
#	target = get_node(target)
#	target = children[rand_int]
	wander_target = self.position
var steering_force = Vector2(0, 0)
func _draw():
#	draw_line(heading, heading*200, Color(1, 1, 1))
	draw_line(Vector2(0, 0), linear_velocity, Color(0, 1, 1))

func _physics_process(delta):
	#f=ma -> a=f/a
	var new_ray_length = calc_ray_length()
	RayLeft.cast_to = new_ray_length
	RayRight.cast_to = new_ray_length
	steering_force = Vector2(0, 0)
	if (flock_type & 1):
		steering_force = seek(target.position, self)
	if (flock_type & 2):
		steering_force = flee(target.position, self)
	if (flock_type & 4):
		steering_force = pursuit(target, self)
	if (flock_type & 8):
		steering_force = evade(target, self)
	if (flock_type & 16):
		steering_force = wander()
	if (flock_type & 32):
		var potential_avoid = self.wall_avoid()
		if (potential_avoid.length() > 0):
			steering_force = potential_avoid
	var acceleration = steering_force / MASS
	velocity  += acceleration * delta
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

	linear_velocity = velocity
	update()
	

