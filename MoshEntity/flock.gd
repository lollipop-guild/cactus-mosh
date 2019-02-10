extends RigidBody2D

export var MASS = 1
export var MAX_SPEED = 100
export var MAX_FORCE = 10
export var MAX_TURN_RATE = 2
export(NodePath) var target
export(int, FLAGS, "Seek", "flee", "Pursuit", "Evade", "Wander", "Wall Avoid", "Object Avoid", "seek_point") var flock_type
var wander_target
export var wander_jitter = 500
export var wander_radius = 2000
export var wander_distance = 20
var RayLeft
var RayRight
var col_start = Vector2(0, 0)
var col_end = Vector2(0, 0)

func flee(target, object):
	var desired_vec = object.position - target
	desired_vec = desired_vec.normalized() * MAX_SPEED
	return(object.get_linear_velocity() - desired_vec)

func seek(target_pos, object):
	var desired_vec = object.position - target_pos
	desired_vec = desired_vec.normalized() * object.MAX_SPEED
	return(desired_vec - object.get_linear_velocity())

#Don't use seek until arrive, need to figure in distance from the actual destination, not the
#intermediary points.
#func seek_point(seek_point, decel, object):
##	var desired_vec = seek_point - object.get_global_transform().origin
##	desired_vec = desired_vec.normalized() * max_speed
##	return(desired_vec - object.get_linear_velocity())
##	
#	var target_vec = seek_point
#	var curr_vec = object.get_global_transform().origin
#	var vec_to = target_vec - curr_vec
#	var distance_to = vec_to.length()
	
#	if distance_to > 2:
#		var decel_tweak = 0.3
#		var speed = distance_to / decel * decel_tweak
#		#Make sure speed doesn't exceed the max speed
#		min(speed, max_speed)
#		var desired_vec = vec_to * speed / distance_to
#		return(desired_vec - object.get_linear_velocity())
#	return(-object.get_linear_velocity())

#func seek_pos(target, object):
#	var desired_vec = target.normalized() * max_speed
#	return(desired_vec - object.get_linear_velocity())

##takes in a with different speeds (slow, normal, fast)
#func arrive(target, decel, object):
#	var target_vec = target.get_global_transform().origin
#	var curr_vec = object.get_global_transform().origin
#	var vec_to = target_vec - curr_vec
#	var distance_to = vec_to.length()
	
#	if distance_to > 2:
#		var decel_tweak = 0.3
#		var speed = distance_to / decel * decel_tweak
#		#Make sure speed doesn't exceed the max speed
#		min(speed, max_speed)
#		var desired_vec = vec_to * speed / distance_to
#		return(desired_vec - object.get_linear_velocity())
#	return(-object.get_linear_velocity())

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

#func evade(pursuer, object):
#	#If the evader is in front of the seeker, then just seek
#	var pursuer_pos = pursuer.get_global_transform().origin
#	var curr_pos = object.get_global_transform().origin
#	var to_pursuer = pursuer_pos - curr_pos
#	var look_ahead_time = to_pursuer.length() / (max_speed + pursuer.get_linear_velocity().length())
#	var evade_targ = object.get_node("TestCube")
#	evade_targ.set_global_transform(Transform(evade_targ.get_transform().basis, (pursuer_pos + pursuer.get_linear_velocity() * look_ahead_time)))
#	return flee(evade_targ, object)

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
	return min_ray_length + (self.linear_velocity / self.MAX_SPEED) * min_ray_length

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
	return ray.get_collision_normal() * overshoot.length()

##Need to add the braking force
#func object_avoid(object, area):
#	if area.get_overlapping_bodies().size() > 0:
#		return calc_object_avoid(object, area)
		
#func calc_object_avoid(object, area):
#	var col_obj = calc_closest_object(object, area)
#	var SteeringForce = Vector3(0,0,0)

#	var multiplier = 1.0 + area.get_shape(0).get_extents().z - area.get_overlapping_bodies()[0].get_global_transform().origin.z
#	#Converting an object to the local coordinate is done implicitly. Experiment. 
#	#Testing the local vs world coordinates
##	var test_obj = object.get_node("TestCube")
##	test_obj.set_transform(Transform(test_obj.get_transform().basis, col_obj.get_global_transform().origin - object.get_global_transform().origin + Vector3(0, 4,0)))
##	test_obj.translate(Vector3(0, 4, 0))
#	var col_obj_local = col_obj.get_global_transform().origin - object.get_global_transform().origin
#	SteeringForce.x += (col_obj.get_scale().x/2 - col_obj_local.x) *multiplier
	
#	#now to calculate the braking force. 
#	var braking_weight = .2
#	SteeringForce.z += (col_obj.get_scale().z/2 - col_obj_local.z) * braking_weight
#	return SteeringForce
	
##calculates the closest object. Currently used in object avoidance to get the closest object to avoid
#func calc_closest_object(object, area):
#	var minimum = area.get_overlapping_bodies()[0]
#	for i in area.get_overlapping_bodies():
#		var local_pos = i.get_global_transform().origin - object.get_global_transform().origin
#		if (minimum.get_global_transform().origin - object.get_global_transform().origin > local_pos):
#			minimum = i
#	return minimum
#func _init(mass, max_speed, max_force, max_turn_rate):
#	self.mass = mass
#	self.max_speed = max_speed
#	self.max_force = max_force
#	self.max_turn_rate = max_turn_rate
#	self.velocity = velocity

