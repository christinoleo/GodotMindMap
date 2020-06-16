extends Button

var url := "http://www.google.com"

func _on_Link_pressed():
	OS.shell_open(url)
