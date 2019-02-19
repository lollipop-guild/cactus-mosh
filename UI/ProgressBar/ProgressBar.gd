extends HBoxContainer

var maximum_moshage = false

func _ready():
	update_label()

func _process(delta):
	$Bar.value = get_node('/root/global').percent_complete
	if $Bar.value >= 100:
		if not maximum_moshage && $"../MaxMoshTimer".time_left == 0:
			maximum_moshage = true
			$"../MaxMoshTimer".start()
			$"../MoshageAnims".play("MaximumMoshage")
		
		if maximum_moshage && $"../MaxMoshTimer".time_left == 0:
			maximum_moshage = false
			$"../MoshageAnims".stop()
			$"/root/global".percent_complete = 0.0
			$"/root/global".level += 1
			update_label()

func update_label():
	$MarginContainer/Level.text = str($"/root/global".level)
	