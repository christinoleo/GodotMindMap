extends GraphEdit

export(NodePath) var inspector
export(NodePath) var savedialogue
export(NodePath) var loaddialogue
export(NodePath) var console
onready var graph_node = preload("res://graph/GraphNode.tscn")

var zoom_active := false

var copy = []
export var save_path := "res://savegraph.save"


# Called when the node enters the scene tree for the first time.
func _ready():
	load_save()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
	if event.is_action_pressed("saveas"):
		get_node(savedialogue).popup_centered()
	elif event.is_action_pressed("save"):
		save()
	if event.is_action_pressed("zoom_active"):
		zoom_active = true
	elif event.is_action_released("zoom_active"):
		zoom_active = false
		
		
func _input(event):
	if event.is_action_pressed("zoom_in") and zoom_active:
		zoom += 0.1
		accept_event()
	if event.is_action_pressed("zoom_out") and zoom_active:
		zoom -= 0.1
		accept_event()
		
	if event.is_action_pressed("option_menu"):
		new_node(get_viewport().get_mouse_position())
		accept_event()
	

func save(path := save_path):
	var save_graph = File.new()
	save_graph.open(path, File.WRITE)
	var node_data = []
	for c in get_children():
		if c is GraphNode:
			node_data.append({"name": c.name, 
								"offset_x":c.get_offset().x, 
								"offset_y":c.get_offset().y,
								"data": c.get_data()})
	var data = {"connections": get_connection_list(), "nodes": node_data}
	save_graph.store_line(to_json(data))
	save_graph.close()
	print("saved!")
	get_node(console).send("saved at " + path)

func load_save(path := save_path):
	var save_graph = File.new()
	if not save_graph.file_exists(path):
		return # Error! We don't have a save to load.
		
	# clear graphedit
	for c in get_children(): 
		if c is GraphNode: 
			c.free()
	
	save_graph.open(path, File.READ)
	var save_data = parse_json(save_graph.get_line())
	for node in save_data["nodes"]:
		var graph_node_instance = graph_node.instance()
		add_child(graph_node_instance)
		graph_node_instance.name = node["name"]
		graph_node_instance.set_offset(Vector2(float(node["offset_x"]), float(node["offset_y"])))
		graph_node_instance.set_data(node["data"])
	
	for conn in save_data["connections"]:
		connect_node(conn["from"], conn["from_port"], conn["to"], conn["to_port"])
	save_graph.close()
	print("loaded!")
	get_node(console).send("loaded " + path)

func get_connections(node_name):
	var ret = {"left": [], "right": []}
	for conn in get_connection_list():
		if node_name == conn["from"]: ret["right"].append(conn["to"])
		elif node_name == conn["to"]: ret["left"].append(conn["from"])
	return ret
	
	
func disconnect_connections_of_node(node_name):
	var conn = get_connections(node_name)
	for c in conn["left"]: disconnect_node(c, 0, node_name, 0)
	for c in conn["right"]: disconnect_node(node_name, 0, c, 0)


func new_node(position:Vector2, title:="Title"):
	var new_node = graph_node.instance()
	new_node.set_offset(position)
	new_node.name = new_node.title
	add_child(new_node)

## CONNECTIONS ##

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	connect_node(from, from_slot, to, to_slot)


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)


func _on_GraphEdit_delete_nodes_request():
	for c in get_children():
		if c is GraphNode and c.is_selected():
			disconnect_connections_of_node(c.name)
			c.queue_free()


func _on_GraphEdit_copy_nodes_request():
	copy.clear()
	for c in get_children():
		if c is GraphNode and c.is_selected():
			copy.append(c)


func _on_GraphEdit_paste_nodes_request():
	for c in copy:
		var new_c = c.duplicate()
		new_c.set_selected(false)
		new_c.set_offset(get_viewport().get_mouse_position()-Vector2(new_c.rect_size.x, 0)/2)
		add_child(new_c)
		new_c.name = String(randi())


func _on_GraphEdit_duplicate_nodes_request():
	for c in get_children():
		if c is GraphNode and c.is_selected():
			var new_c = c.duplicate()
			new_c.set_selected(false)
			new_c.set_offset(get_viewport().get_mouse_position()-Vector2(new_c.rect_size.x, 0)/2)
			new_c.name = new_c.title
			add_child(new_c)


func _on_newnode_pressed():
	new_node(scroll_offset + get_viewport_rect().size/2)


func _on_save_pressed():
	save()


func _on_saveas_pressed():
	get_node(savedialogue).show()


func _on_SaveDialog_file_selected(path):
	save(path)


func _on_LoadDialog_file_selected(path):
	load_save(path)


func _on_load_pressed():
	get_node(loaddialogue).popup_centered()


func _on_GraphEdit_node_selected(node):
	get_node(inspector).activate(node)


func _on_GraphEdit_node_unselected(node):
	get_node(inspector).hide()
