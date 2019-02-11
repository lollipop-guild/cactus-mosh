extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed('ui_accept'):
		if $Bar.value >= 100:
			get_node('/root/global').percent_complete = 0
			get_node('/root/global').goto_scene("res://main.tscn")
			get_tree().paused = false

func _process(delta):
	$Bar.value = get_node('/root/global').percent_complete
	if $Bar.value >= 100:
		get_tree().paused = true
		$Label.show()