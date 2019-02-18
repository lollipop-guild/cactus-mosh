extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var percent_complete = 0.0
var level = 0
var game_over = false

# Called when the node enters the scene tree for the first time.

var current_scene = null

var score = []

class MyCustomSorter:
	static func sort(a, b):
		if a.score > b.score:
			return true
		return false

func get_score():
	return score

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	score = initialize_score()

func initialize_score():
#	if OS.has_feature('JavaScript'):
#		return load_from_local_storage()
#	else:
#		return load_from_disk()
	return load_from_disk()

func load_from_local_storage():
	var init_json = JavaScript.eval("var gameState = localStorage.getItem('gameState'); gameState;")
	if init_json != null:
		var game_state = parse_json(init_json)
		return game_state[name.to_lower()]
	else:
		return score

func save_game(name):
	add_to_high_score(name, self.percent_complete, self.level)
#	if OS.has_feature('JavaScript'):
#		var game_state = to_json(score)
#		JavaScript.eval("localStorage.setItem('gameState', '%s');" % game_state )
#	else:
#		var game_state = JSON.print(score, "    ", true)
#		var save_file = File.new()
#		save_file.open("user://save.json", File.WRITE)
#		save_file.store_line(str(game_state))
#		save_file.close()
	var game_state = JSON.print(score, "    ", true)
	var save_file = File.new()
	save_file.open("user://save.json", File.WRITE)
	save_file.store_line(str(game_state))
	save_file.close()

func add_to_high_score(name, percent, level):
	var total_score = ((level*100) + percent)
	score.append({"name": name, "score": total_score})
	score.sort_custom(MyCustomSorter, "sort")

func load_from_disk():
	var f = File.new()
	if f.file_exists("user://save.json"):
		f.open("user://save.json", File.READ)
		var save_json = f.get_as_text()
		var saved_state = parse_json(save_json)
		if saved_state and typeof(saved_state) == TYPE_ARRAY:
			return saved_state
		else:
			return score
	else:
		f.open("user://save.json", File.WRITE)
		f.store_string("{}")
		f.close()
		return score

func goto_scene(path):
    # This function will usually be called from a signal callback,
    # or some other function from the running scene.
    # Deleting the current scene at this point might be
    # a bad idea, because it may be inside of a callback or function of it.
    # The worst case will be a crash or unexpected behavior.

    # The way around this is deferring the load to a later time, when
    # it is ensured that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)

func end_game():
	game_over = true

func _deferred_goto_scene(path):
    # Immediately free the current scene,
    # there is no risk here.
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	current_scene.free()

    # Load new scene.
	var s = ResourceLoader.load(path)

    # Instance the new scene.
	current_scene = s.instance()

    # Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

    # Optional, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
