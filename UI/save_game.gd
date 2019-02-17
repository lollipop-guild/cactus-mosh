extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var score = {}

func initialize_store(name):
	if OS.has_feature('JavaScript'):
		return load_from_local_storage()
	else:
		return load_from_disk()

func load_from_local_storage():
	var init_json = JavaScript.eval("var gameState = localStorage.getItem('gameState'); gameState;")
	if init_json != null:
		var game_state = parse_json(init_json)
		return game_state[name.to_lower()]
	else:
		return score
		
func load_from_disk():
	var f = File.new()
	if f.file_exists("user://save.json"):
		f.open("user://save.json", File.READ)
		var save_json = f.get_as_text()
		var saved_state = parse_json(save_json)
		if saved_state and saved_state.has(name.to_lower()):
			return saved_state[name.to_lower()]
		else:
			return score
	else:
		f.open("user://save.json", File.WRITE)
		f.store_string("{}")
		f.close()
		return score
		
