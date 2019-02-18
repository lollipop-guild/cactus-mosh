extends CanvasLayer

func _ready():
	pass

func _process(delta):
	if global.percent_complete > 50:
		$AnimationPlayer.play("BananaBeware")
	else:
		$AnimationPlayer.play("Base")

func _on_Restart_pressed():
	global.game_over = false
	get_node('/root/global').goto_scene("res://main.tscn")

func _on_Quit_pressed():
	global.game_over = false
	get_node('/root/global').goto_scene("res://TitleScreen/MainMenu.tscn")

func _on_Button_button_down():
	get_node('/root/global').save_game($HighScoreMenuWoo/VBox/LineEdit.text)
	$HighScoreMenuWoo.hide()
	$GameOverMenu.show()
