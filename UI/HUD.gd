extends CanvasLayer

func _ready():
	pass

func _on_Restart_pressed():
	global.game_over = false
	get_node('/root/global').goto_scene("res://main.tscn")

func _on_Quit_pressed():
	global.game_over = false
	get_node('/root/global').goto_scene("res://TitleScreen/MainMenu.tscn")
