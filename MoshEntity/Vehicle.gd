extends "res://MoshEntity/flock.gd"

var heading = Vector2(0, 1)
var velocity = Vector2(0, 0)
var side
export var min_velocity = Vector2(10, 10)
export var seek_flee_multiplier = 2.0

var sprites = [
	preload("res://Fruit/Textures/AppleRef.png"),
	preload("res://Fruit/Textures/PearRef.png"),
	preload("res://Fruit/Textures/OrangeRef.png")
	]
	
func _ready():
	RayRight = $Position2D/RayRight
	RayLeft  = $Position2D/RayLeft
	RayRight.add_exception(self)
	RayLeft.add_exception(self)
	var children = get_parent().get_children()
	var rand_int = randi() % children.size()
#	target = children[rand_int]
	wander_target = self.position
	set_random_sprite()

func set_random_sprite():
	var rand_int = randi() % sprites.size()
	$Position2D/Sprite.texture = sprites[rand_int]

var steering_force = Vector2(0, 0)

func _draw():
#	draw_line(heading, heading*200, Color(1, 1, 1))
	draw_line(Vector2(0, 0), target, Color(0, 1, 1))

func set_target(target):
	self.target = to_local(target)

func _integrate_forces(state):
	#f=ma -> a=f/a
	var new_ray_length = calc_ray_length()
	RayLeft.cast_to = new_ray_length
	RayRight.cast_to = new_ray_length
	steering_force = Vector2(0, 0)
	if linear_velocity.length() > min_velocity.length():
		flock_type = flock_type ^ 128
	if (flock_type & 1):
		steering_force += seek(target, self)
		steering_force * seek_flee_multiplier
	if (flock_type & 2):
		steering_force += flee(target, self)
		steering_force * seek_flee_multiplier
	if (flock_type & 4):
		steering_force = pursuit(target, self)
	if (flock_type & 8):
		steering_force = evade(target, self)
	if (flock_type & 16):
		steering_force += wander()
	if (flock_type & 32):
		var potential_avoid = self.wall_avoid()
		if (potential_avoid.length() > 0):
			steering_force += potential_avoid
	if (flock_type & 128):
		steering_force = Vector2(0, 0)
	
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

	linear_velocity = velocity
	update()
	

