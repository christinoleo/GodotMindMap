extends PopupDialog


export(NodePath) var graph_edit


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

onready var title := $MarginContainer/VBoxContainer/HBoxContainer/TextEdit
onready var color_frame := $MarginContainer/VBoxContainer/HBoxContainer2/ColorFrame
onready var color_selected := $MarginContainer/VBoxContainer/HBoxContainer3/ColorSelected
onready var link_container := $MarginContainer/VBoxContainer/Links
onready var add_link_text := $MarginContainer/VBoxContainer/newlinkcontainer/text
onready var add_link_url := $MarginContainer/VBoxContainer/newlinkcontainer/url
var active_node : GraphNode
onready var original_size := get_size()

func activate(node):
	active_node = node
	title.text = node.title
	color_frame.color = node.get("custom_styles/frame").get_border_color()
	color_selected.color = node.get("custom_styles/selectedframe").get_border_color()
	popup_centered()
	title.grab_focus()
	load_links()
	

func load_links():
	var links = active_node.get_links()
	for c in link_container.get_children(): link_container.remove_child(c)
	for link in links:
		var hbox = HBoxContainer.new()
		hbox.set_h_size_flags(3)
		var label_text = Label.new()
		label_text.text = link["text"]
		label_text.set_h_size_flags(3)
		hbox.add_child(label_text)
		var label_url = Label.new()
		label_url.text = link["url"]
		label_url.set_h_size_flags(3)
		hbox.add_child(label_url)
		var delete = Button.new()
		delete.set_h_size_flags(3)
		delete.text = "Delete"
		delete.connect("pressed", self, "_on_link_delete", [label_text.text])
		hbox.add_child(delete)
		link_container.add_child(hbox)
	print(link_container.get_combined_minimum_size())
	set_size(original_size + Vector2(0, link_container.get_combined_minimum_size().y))
	update()


func _on_link_delete(text):
	active_node.remove_link(text)
	load_links()


func _on_Save_pressed():
	get_node(graph_edit).save()
	hide()


func _on_ColorSelected_color_changed(color):
	active_node.set_border_color_rgb(color_frame.color, color_selected.color)


func _on_ColorFrame_color_changed(color):
	active_node.set_border_color_rgb(color_frame.color, color_selected.color)


func _on_TextEdit_text_changed(new_text):
	active_node.set_title(title.text)
	active_node.name = title.text


func _on_AddLink_pressed():
	active_node.add_link(add_link_text.text, add_link_url.text)
	load_links()
