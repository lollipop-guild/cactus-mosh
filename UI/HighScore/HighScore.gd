extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	populate_score_board($"/root/global".score)
	$VBoxContainer/Button.connect("button_down", self, "goto_main")
	
func goto_main():
	$"/root/global".goto_scene("res://TitleScreen/MainMenu.tscn")
	
func populate_score_board(scores):
	print(scores)
	for score in scores:
		print(score)
		var label = Label.new()
		label.text = score.name + ": " + str(score.score)
		$VBoxContainer/ScrollContainer/Scores.add_child(label)