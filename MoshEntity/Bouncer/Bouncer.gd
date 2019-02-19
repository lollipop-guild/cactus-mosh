extends "res://MoshEntity/Vehicle.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dash = Vector2(0, 0)
export var DASH_SPEED = 10
# Called when the node enters the scene tree for the first time.
var player_pos = Vector2(0, 0)
var players
var playback
export var will_dash_distance = 250
export var seek_range = 800
var default_scale

func _ready():
	self.connect('body_entered', self, '_handle_collision')
	players = get_tree().get_nodes_in_group("players")
	playback = $art/AnimationTree.get("parameters/playback")
	playback.start("Idle")
	default_scale = $art.scale
	$art/Light2D.visible = false

func _handle_collision(body):
	if body.is_in_group('players'):
		body.knockdown()
	dash = Vector2(0, 0)
	playback.start("Idle")

func _integrate_forces(state):
	._integrate_forces(state)
	if dash.length() > 0:
		state.set_linear_velocity(dash)

func _draw():
	._draw()
	if debug_text:
		if target:
			draw_line(Vector2(0, 0), to_local(target.global_position), Color(0, 1, 1))
		draw_line(Vector2(0, 0), player_pos, Color(0, 1, 1))

func _process(delta):
	for player in players:
		# Delete if too far away
		var to_player = player.global_position.distance_to(self.global_position)

		if to_player < seek_range && global.percent_complete > 50:
			flock_type = 1
			$art/Light2D.visible = true
			# Dash if close
			if to_player < will_dash_distance:
				var is_facing_player = check_if_facing_player(player)
				if is_facing_player and dash.length() == 0:
					player_pos = to_local(player.global_position)
					dash_to_target(player.global_position)
					playback.start("Dash")
			else:
				dash = Vector2(0, 0)
				playback.start("Walk")
		else:
			flock_type = 64
			$art/Light2D.visible = false
			playback.travel("Idle")
	
	var lv = get_linear_velocity()
	
	if lv.x < 0:
		$art.scale = Vector2(default_scale.x * -1, default_scale.y)
	elif lv.x > 0:
		$art.scale = Vector2(default_scale.x, default_scale.y)

func dash_to_target(pos):
	var BP = pos - self.global_position
	heading = BP.normalized()
	dash = BP.normalized() * DASH_SPEED

func check_if_facing_player(body):
	var BP = (body.global_position - self.global_position).normalized()
	if BP.dot(self.heading) > 0:
		return true
	return false
