extends Control

func _ready():
	$Button.connect("button_down", self, "goto_main")
	
func goto_main():
	$"/root/global".goto_scene("res://TitleScreen/MainMenu.tscn")
