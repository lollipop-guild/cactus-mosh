extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var area_size = Vector2(128, 128)
var area = preload("res://Main/area.tscn")
var most_dense
# Called when the node enters the scene tree for the first time.
func _ready():
	create_world_grid()
	
func create_world_grid():
	var num_col = OS.get_screen_size().x / area_size.x 
	var num_row = OS.get_screen_size().y / area_size.y
	for col in num_col:
		for row in num_row:
			var instance = area.instance()
			instance.area_size = area_size
			var new_pos = Vector2(col*area_size.x*2, row*area_size.y*2)
			instance.position = new_pos
			$AreaContainer.add_child(instance)

func find_most_dense():
	var most_bodies = $AreaContainer.get_children()[0]
	for child in $AreaContainer.get_children():
		if most_bodies.get_overlapping_bodies().size() < child.get_overlapping_bodies().size():
			most_bodies = child
	return most_bodies

func set_seek_target(new_target):
	for mosher in get_tree().get_nodes_in_group('mosher'):
		mosher.set_target(to_local(new_target.position))

func _process(delta):
	var prev_dense = most_dense
	most_dense = find_most_dense()
	if prev_dense != most_dense:
		if prev_dense:
			prev_dense.remove_highlight()
		most_dense.highlight()
		set_seek_target(most_dense)