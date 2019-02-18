extends HBoxContainer

func _ready():
	update_label()

func _process(delta):
	$Bar.value = get_node('/root/global').percent_complete
	if $Bar.value >= 100:
		$"/root/global".percent_complete = 0.0
		$"/root/global".level += 1
		update_label()

func update_label():
	$MarginContainer/Level.text = str($"/root/global".level)
	