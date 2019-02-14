extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	update_label()

func _input(event):
	if event.is_action_pressed('ui_accept'):
		if $Bar.value >= 100:
			get_node('/root/global').percent_complete = 0
			get_node('/root/global').goto_scene("res://main.tscn")
			get_tree().paused = false

func _process(delta):
	$Bar.value = get_node('/root/global').percent_complete
	if $Bar.value >= 100:
		$"/root/global".percent_complete = 0.0
		$"/root/global".level += 1
		update_label()

func update_label():
	$MarginContainer/Level.text = str($"/root/global".level)
	