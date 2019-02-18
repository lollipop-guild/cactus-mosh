extends Button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("button_down", self, "goto_high_score")

func goto_high_score():
	$"/root/global".goto_scene("res://UI/HighScore/HighScore.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
