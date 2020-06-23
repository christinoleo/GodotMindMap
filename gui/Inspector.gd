extends PanelContainer

export(NodePath) var graph_edit

onready var url_manager := preload("res://extra/UrlManager.tscn")

onready var container := $MarginContainer
onready var title := $MarginContainer/VBoxContainer/HBoxContainer/TextEdit
onready var color_frame := $MarginContainer/VBoxContainer/HBoxContainer2/ColorFrame
onready var color_selected := $MarginContainer/VBoxContainer/HBoxContainer3/ColorSelected
onready var link_container := $MarginContainer/VBoxContainer/Links
onready var add_link_text := $MarginContainer/VBoxContainer/newlinkcontainer/text
onready var add_link_url := $MarginContainer/VBoxContainer/newlinkcontainer/url
var active_node : GraphNode
onready var original_size := get_size()


func _ready():
	hide()


func activate(node):
	active_node = node
	title.text = node.title
	color_frame.color = node.get("custom_styles/frame").get_border_color()
	color_selected.color = node.get("custom_styles/selectedframe").get_border_color()
	title.grab_focus()
	load_links()
	show()
	

func load_links():
	var links = active_node.get_links()
	for c in link_container.get_children(): link_container.remove_child(c)
	for i in range(links.size()):
		var link = links[i]
		var url_manager_instance:UrlManager = url_manager.instance()
		link_container.add_child(url_manager_instance)
		url_manager_instance.set_type(UrlManager.Type.TYPE_REMOVE)
		url_manager_instance.load_link(link["text"], link["url"])
		url_manager_instance.connect("on_text", self, "_on_link_update_text", [link, i])
		url_manager_instance.connect("on_url", self, "_on_link_update_url", [link, i])
		url_manager_instance.connect("on_pressed", self, "_on_link_delete", [link, i])
	hide()
	show()
#	print(link_container.get_combined_minimum_size())
#	set_size(original_size + Vector2(0, link_container.get_combined_minimum_size().y))
	update()


func _on_link_delete(text, url, link, idx):
	active_node.remove_link(idx)
	load_links()

func _on_link_update_url(url, link, idx):
	active_node.update_link(idx, link["text"], url)
#	link_container.get_child(idx).load_link(link["text"], url)

func _on_link_update_text(text, link, idx):
	active_node.update_link(idx, text, link["url"])
#	link_container.get_child(idx).load_link(text, link["url"])


func _on_ColorSelected_color_changed(color):
	active_node.set_border_color_rgb(color_frame.color, color_selected.color)


func _on_ColorFrame_color_changed(color):
	active_node.set_border_color_rgb(color_frame.color, color_selected.color)


func _on_TextEdit_text_changed(new_text):
	active_node.set_title(title.text)
	active_node.name = title.text


func _on_AddLink_pressed(text, url):
	active_node.add_link(text, url)
	load_links()
