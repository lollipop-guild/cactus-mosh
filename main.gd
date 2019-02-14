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

func _ready():
	create_world_grid()
	instance_bouncer()

func create_world_grid():
	var size = $Environment/Background.texture.get_size() * $Player/Camera2D.zoom
	var num_col = size.x / area_size.x
	var num_row = size.y / area_size.y

	for col in num_col:
		for row in num_row:
			var instance = area.instance()
			instance.area_size = area_size
			var new_pos = Vector2(col*area_size.x*2, row*area_size.y*2)
			instance.position = new_pos
			$AreaContainer.add_child(instance)

func _process(delta):
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

func calc_new_spawn_time():
	return default_spawn - (most_dense.weight * $"/root/global".level)

func instance_bouncer():
	randomize()
	var center = $Player/Camera2D.get_camera_screen_center()
	var rand_x = rand_range(-1, 1)
	var rand_y = rand_range(-1, 1)
	var rand_vect = Vector2(rand_x, rand_y)
	rand_vect = (rand_vect.normalized()*800)+center
	var temp = bouncer.instance()
	temp.position = rand_vect
	add_child(temp)

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
