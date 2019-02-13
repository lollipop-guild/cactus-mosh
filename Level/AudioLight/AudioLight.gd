extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var audio_server

func _ready():
	audio_server = AudioServer

func _process(delta):
	#TODO: Find a more effective way to normalize audio
	$Light2D.energy = lerp($Light2D.energy, audio_server.get_bus_peak_volume_left_db(0, 0)+20, .05)
	print($Light2D.energy)