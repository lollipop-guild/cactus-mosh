extends "res://MoshEntity/Vehicle.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect('body_entered', self, 'check_if_player')

func body_entered(body):
	if body.is_in_group('players'):
		get_node('/root/global').go_to_scene("res://main.tscn")