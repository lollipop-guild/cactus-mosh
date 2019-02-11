extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var WALK_MAX_VELOCITY = 100
export var WALK_ACCEL = 100
export var WALK_DEACCEL = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _integrate_forces(state):
	var move_left = Input.is_action_pressed("walk_left")
	var move_right = Input.is_action_pressed("walk_right")
	var move_up = Input.is_action_pressed("walk_up")
	var move_down = Input.is_action_pressed("walk_down")
	var lv = state.get_linear_velocity()
	var step = state.step
	if move_left and not move_right:
		if lv.x > -WALK_MAX_VELOCITY:
			lv.x -= WALK_ACCEL * step
	elif move_right and not move_left:
		if lv.x < WALK_MAX_VELOCITY:
			lv.x += WALK_ACCEL * step
	if move_up and not move_down:
		if lv.y > -WALK_MAX_VELOCITY:
			lv.y -= WALK_ACCEL * step
	elif move_down and not move_up:
		if lv.y < WALK_MAX_VELOCITY:
			lv.y += WALK_ACCEL * step
	else:
		var xv = abs(lv.x)
		xv -= WALK_DEACCEL * step
		if xv < 0:
			xv = 0
		lv.x = sign(lv.x) * xv
	print(move_down, lv)
	state.set_linear_velocity(lv)