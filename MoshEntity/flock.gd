extends RigidBody2D

export var MAX_SPEED = 100.0
export var MAX_FORCE = 10.0
export var MAX_TURN_RATE = .1
export (NodePath) var target = self.get_path()
export(int, FLAGS, "Seek", "flee", "Pursuit", "Evade", "Wander", "Wall Avoid", "idle") var flock_type
var wander_target
export var wander_jitter = 500
export var wander_radius = 2000
export var wander_distance = 20
var RayLeft
var RayRight
var col_start = Vector2(0, 0)
var col_end = Vector2(0, 0)

func flee(target, object):
	var desired_vec =  target - object.position
	desired_vec = desired_vec.normalized() * MAX_SPEED
	return(object.get_linear_velocity() - desired_vec)

func seek(target_pos, object):
	var desired_vec =  target_pos - object.position
	desired_vec = desired_vec.normalized() * object.MAX_SPEED
	return((desired_vec - object.get_linear_velocity()) * (object.position.distance_to(target_pos)) / 200)

func pursuit(evader, object):
	#If the evader is in front of the seeker, then just seek
	var evader_pos = evader.position
	var to_evader = evader_pos - self.position
	var relative_heading = object.heading.dot(evader.heading)
	if( to_evader.dot(object.heading) > 0 and relative_heading < -0.95):
		return seek(evader, object)
	else:
		var look_ahead_time = to_evader.length() / (self.MAX_SPEED + evader.get_linear_velocity().length())
		evader_pos = evader_pos + evader.get_linear_velocity() * look_ahead_time
		return seek(evader_pos, object)

func evade(pursuer, object):
	#If the pursuer is in front of the seeker, then just seek
	var pursuer_pos = pursuer.position
	var to_pursuer = pursuer_pos - self.position
	var relative_heading = object.heading.dot(pursuer.heading)
	var look_ahead_time = to_pursuer.length() / (self.MAX_SPEED + pursuer.get_linear_velocity().length())
	pursuer_pos = pursuer_pos + pursuer.get_linear_velocity() * look_ahead_time
	return flee(pursuer_pos, object)

func wander():
	wander_target += Vector2(rand_range(-1, 1) * wander_jitter, rand_range(-1, 1) * wander_jitter)
	wander_target = wander_target.normalized()
	wander_target *= wander_radius
	#reprojecting 
	var target_local = wander_target + Vector2(0, -wander_distance)
	return seek(target_local, self)
	
#Function is not taking into account the closest wall. So, it gets stuck in corners right now.
func wall_avoid():
	var SteeringForce = Vector2(0, 0)
	if RayLeft.is_colliding() or RayRight.is_colliding():
		var position_to_right = self.position.distance_to(RayLeft.get_collision_point())
		var position_to_left = self.position.distance_to(RayRight.get_collision_point())
		if position_to_left < position_to_right:
			SteeringForce = calc_wall_vel(self, RayLeft)
		else:
			SteeringForce = calc_wall_vel(self, RayRight)
	return SteeringForce

var min_ray_length = Vector2(0, 150)

func calc_ray_length():
	return min_ray_length + (Vector2(abs(self.linear_velocity.x), abs(self.linear_velocity.y)) / self.MAX_SPEED) * min_ray_length

func calc_wall_vel(object, ray):
	var dist_to_col = (ray.get_collision_point() - object.get_global_transform().origin)
	var overshoot = (object.get_global_transform().origin + ray.get_cast_to()) - ray.get_collision_point()
	#Creating a steering force in the direction of the wall normal with the magnitude
	#of the overshoot
	col_start = to_local(ray.get_collision_point())
	col_end = to_local(ray.get_collision_point() + ray.get_collision_normal() * overshoot.length())
	update()
	wander_target = -ray.get_collision_normal() * overshoot.length()*wander_distance
	wander_target = wander_target.normalized()
	return ray.get_collision_normal() * (pow(overshoot.length(), 1.3))