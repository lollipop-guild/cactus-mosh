extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var area_size = Vector2(128, 128)
var area = preload("res://Main/area.tscn")
var most_dense
var default_spawn = 35
var spawn_time = default_spawn
var bouncer = preload("res://MoshEntity/Bouncer/Bouncer.tscn")
var size_of_map
var closest_bouncer
var player

func _ready():
	create_world_grid()
	closest_bouncer = instance_bouncer()
	player = get_tree().get_nodes_in_group("players")[0]
	$AudioStreamPlayer.play()
	$AudioStreamPlayer2D.play()

func create_world_grid():
	size_of_map = $Environment/Background.texture.get_size() * $YSort/Player/Camera2D.zoom
	var num_col = size_of_map.x / area_size.x
	var num_row = size_of_map.y / area_size.y

	for col in num_col:
		for row in num_row:
			var instance = area.instance()
			instance.area_size = area_size
			var new_pos = Vector2(col*area_size.x*2, row*area_size.y*2)
			instance.position = new_pos
			$AreaContainer.add_child(instance)

func _process(delta):
	move_audio_to_closest_bouncer()
	var prev_dense = most_dense
	most_dense = find_most_dense()
	spawn_time -= delta
	if spawn_time < 0:
		spawn_time = calc_new_spawn_time()
		for i in range($"/root/global".level):
			instance_bouncer()
	if prev_dense and prev_dense.target != most_dense.target:
		prev_dense.target.remove_highlight()
		most_dense.target.highlight()
		set_seek_target(most_dense)
	
	if global.game_over:
		$CanvasLayer/GameOverMenu.visible = true

func move_audio_to_closest_bouncer():
	for bouncer in get_tree().get_nodes_in_group("bouncers"):
		var closest_bouncer_to_player = player.global_position.distance_to(closest_bouncer.global_position)
		var bouncer_to_player = player.global_position.distance_to(bouncer.global_position)
		if closest_bouncer_to_player < bouncer_to_player:
			closest_bouncer = bouncer
	$AudioStreamPlayer2D.global_position = closest_bouncer.global_position

func calc_new_spawn_time():
	print(most_dense.weight)
	return default_spawn - (most_dense.weight * $"/root/global".level)

func instance_bouncer():
	randomize()
	var center = $YSort/Player/Camera2D.get_camera_screen_center()
	var rand_x = rand_range(-1, 1)
	var rand_y = rand_range(-1, 1)
	var rand_vect = Vector2(rand_x, rand_y)
	rand_vect = (rand_vect.normalized()*800)+center
	rand_vect = adjust_vector_in_bound(rand_vect)
	var temp = bouncer.instance()
	temp.position = rand_vect
	add_child(temp)
	return temp

func adjust_vector_in_bound(rand_vect):
	if rand_vect.x > size_of_map.x:
		rand_vect.x -= 1600
	if rand_vect.x < 0:
		rand_vect.x += 1600
	if rand_vect.y > size_of_map.y:
		rand_vect.y -= 1600
	if rand_vect.y < 0:
		rand_vect.y += 1600
	return rand_vect

func find_most_dense():
	var most_bodies = $AreaContainer.get_children()[0]
	var mb_weight
	for child in $AreaContainer.get_children():
		mb_weight = get_mosh_weight(most_bodies.get_overlapping_bodies())
		var child_weight = get_mosh_weight(child.get_overlapping_bodies())
		if mb_weight < child_weight:
			most_bodies = child
	return { "target": most_bodies, "weight": mb_weight }

func set_seek_target(most_dense):
	for mosher in get_tree().get_nodes_in_group('mosher'):
		mosher.set_target(most_dense.target)
	for bouncer in get_tree().get_nodes_in_group('bouncers'):
		bouncer.set_target(most_dense.target)


func get_mosh_weight(bodies):
	var weight = 0
	for body in bodies:
		if body.is_in_group('moshers'):
			weight += body.mosh_weight
	return weight
