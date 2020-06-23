extends HBoxContainer

class_name UrlManager

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal on_text(text)
signal on_url(url)
signal on_pressed(text, url)

enum Type {
	TYPE_ADD,
	TYPE_REMOVE
}

const texts := {
	Type.TYPE_ADD: "Add",
	Type.TYPE_REMOVE: "Remove",
}

export(Type) var type = Type.TYPE_ADD setget set_type

onready var letext := $VBoxContainer/letext
onready var leurl := $VBoxContainer/leurl
onready var button := $Button

func set_type(value):
	type = value
	button.text = texts[value]
	
	
func load_link(text, url):
	letext.text = text
	leurl.text = url

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func _on_Button_pressed():
	emit_signal("on_pressed", letext.text, leurl.text)


func _on_letext_text_changed(new_text):
	emit_signal("on_text", new_text)


func _on_leurl_text_changed(new_text):
	emit_signal("on_url", new_text)
