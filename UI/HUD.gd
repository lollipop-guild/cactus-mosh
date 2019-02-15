extends CanvasLayer

func _on_Restart_pressed():
	get_node('/root/global').goto_scene("res://main.tscn")

func _on_Quit_pressed():
	get_node('/root/global').goto_scene("res://TitleScreen/MainMenu.tscn")
