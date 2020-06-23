extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func send(value):
	text = value
	$Timer.stop()
	$Timer.start(5)


func _on_Timer_timeout():
	text = ""
