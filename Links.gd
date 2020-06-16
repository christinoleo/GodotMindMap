extends VBoxContainer

onready var link_button := preload("res://Link.tscn")

func add_link(text, url):
	var b = link_button.instance()
	b.url = url
	b.text = text
	$container.add_child(b)


func get_links():
	var ret = []
	for c in $container.get_children():
		ret.append({"text": c.text, "url": c.url})
	return ret
	
	
func remove_link(text):
	for c in $container.get_children():
		if c.text == text:
			$container.remove_child(c)
