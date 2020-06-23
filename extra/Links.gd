extends VBoxContainer

onready var link_button := preload("./Link.tscn")

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
	
	
func update_link(idx:int, text:String, url:String):
	if $container.get_child_count() > idx:
		var child = $container.get_child(idx)
		child.text = text
		child.url = url
	
	
func remove_link(idx:int):
	if $container.get_child_count() > idx:
		$container.remove_child($container.get_child(idx))
