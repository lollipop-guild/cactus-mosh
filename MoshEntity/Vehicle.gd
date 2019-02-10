extends "res://MoshEntity/flock.gd"

var heading = Vector2(0, 0)
var velocity = Vector2(0, 0)
var side

func _ready():
	Ray = $Position2D/RayLeft
	var children = get_parent().get_children()
	var rand_int = randi() % children.size()
#	target = get_node(target)
#	target = children[rand_int]
	wander_target = self.position
var steering_force = Vector2(0, 0)
func _draw():
	draw_line(position+wander_target, position+wander_target*20, Color(1, 1, 1))

func _physics_process(delta):
	#f=ma -> a=f/a
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
		heading = velocity.normalized()
		#Need to calc the perp
	linear_velocity = velocity
	$Position2D.look_at(position+heading.rotated(PI/2))
	update()
	

