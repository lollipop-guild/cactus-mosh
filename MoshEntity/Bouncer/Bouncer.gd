extends "res://MoshEntity/Vehicle.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dash = Vector2(0, 0)
export var DASH_SPEED = 10
# Called when the node enters the scene tree for the first time.
var player_pos = Vector2(0, 0)
var players
func _ready():
	self.connect('body_entered', self, '_handle_collision')
	players = get_tree().get_nodes_in_group("players")

func _handle_collision(body):
	if body.is_in_group('players'):
		get_node('/root/global').percent_complete = 0
		get_node('/root/global').goto_scene("res://TitleScreen/MainMenu.tscn")
	dash = Vector2(0, 0)

func _integrate_forces(state):
	._integrate_forces(state)
	if dash.length() > 0:
		state.set_linear_velocity(linear_velocity + dash)

func _draw():
	._draw()
	if debug_text:
		if target:
			draw_line(Vector2(0, 0), to_local(target.global_position), Color(0, 1, 1))
		draw_line(Vector2(0, 0), player_pos, Color(0, 1, 1))

func _process(delta):
	for player in players:
		if player.global_position.distance_to(self.global_position) < 300:
			var is_facing_player = check_if_facing_player(player)
			if is_facing_player and dash.length() == 0:
				player_pos = to_local(player.global_position)
				dash_to_target(player.global_position)
		else:
			dash = Vector2(0, 0)

func dash_to_target(pos):
	var BP = pos - self.global_position
	heading = BP.normalized()
	dash = BP.normalized() * DASH_SPEED

func check_if_facing_player(body):
	var BP = (body.global_position - self.global_position).normalized()
	if BP.dot(self.heading) > 0:
		return true
	return false

#func _process(delta):
#	get_tree().get_nodes_in_group('mosher')
