extends Button

func _ready():
	self.connect("button_down", self, "goto_credits")

func goto_credits():
	$"/root/global".goto_scene("res://Credits/Credits.tscn")