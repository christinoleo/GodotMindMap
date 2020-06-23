extends Resource

class_name BibtexParser

enum STATE {
	OUT,
	IN
}


var state
var file: File
var data: Dictionary

var rSpace := RegEx.new()
var rType := RegEx.new()
var rSubType := RegEx.new()
var rSubTypeEnd := RegEx.new()

var title: String

func _init():
	self.state = STATE.OUT
	rSpace.compile("\\S+")
	rType.compile("@(?<type>\\w*){(?<title>\\S*),")
	rSubType.compile("\\s*(?<type>\\w*)\\s*=\\s*[{|\"](?<text>[^}]*)[}|\"]\\s*,")
	rSubTypeEnd.compile("^\\s*}$")

func execute(line):
	if line == "": return
	if rSpace.search(line) == null: return
	
	if state == STATE.OUT and line.begins_with("@"):
		var type = rType.search(line)
		if type == null: 
			print("problem with type ", line)
			return
		title = type.get_string("title")
		
		data[title] = {}
		data[title]["type"] = type.get_string("type")
		state = STATE.IN
	elif state == STATE.IN:
		if rSubTypeEnd.search(line) != null:
			state = STATE.OUT
			return
		var l = rSubType.search(line)
		if l == null:
			print("problem with subtype ", line)
			return
		var type = l.get_string("type")
		var text = l.get_string("text")
		data[title][type] = text
		
	
	
func parse_path(path:String):
	var file = File.new()
	if not file.file_exists(path): return []
	
	file.open(path, File.READ)
	var ret = parse_file(file)
	file.close()
	return ret
	
	
func parse_file(file:File):
	while file.get_position() < file.get_len():
		var line = file.get_line()
		execute(line)
	return data
	
	
func get_data():
	return data
