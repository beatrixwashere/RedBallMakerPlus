# --- block.gd ----
# stores block data
# -----------------
extends Resource
class_name Block
# constants
enum blocktypes {
	POLYGON,
	CIRCLE,
	CHECKPOINT,
	FLAG }
const typestr:Dictionary = {
	blocktypes.POLYGON: "b",
	blocktypes.CIRCLE: "b",
	blocktypes.CHECKPOINT: "s",
	blocktypes.FLAG: "s",
}
const shapestr:Dictionary = {
	blocktypes.POLYGON: "p",
	blocktypes.CIRCLE: "c",
	blocktypes.CHECKPOINT: "cp",
	blocktypes.FLAG: "la",
}
# data
var type:int = blocktypes.POLYGON
var name:String = "0"
var flags:String = ""
var mass:float = 0
var friction:float = 1
var restitution:float = 0.2
var polygon:PackedVector2Array = PackedVector2Array()
var position:Vector2i = Vector2i(0,0)
var radius:float = 25
var fill:Color = Color(0,0,0,1)
# TODO: add textures
var outline:Color = Color(0,0,0,1)
var levelobj:Node
var listobj:Node
# encode into level format
func encode_level()->String:
	var output:String = ""
	# header
	output += typestr[type]+"_"+name+",\n\t"
	# behavior
	if type == blocktypes.POLYGON || type == blocktypes.CIRCLE:
		output += flags+","+str(mass)+","+str(friction)+","+str(restitution)
	elif type == blocktypes.CHECKPOINT || type == blocktypes.FLAG:
		output += "b_ground"
	# shape & color
	output += ":\n\t"+shapestr[type]+","
	if type == blocktypes.POLYGON:
		for i in polygon: output += str(i.x)+","+str(i.y)+","
		output = output.erase(output.length()-1)
		output += ":\n\t0x"+fill.to_html(false)+",1:1,0x"+outline.to_html(false)
	if type == blocktypes.CIRCLE:
		output += str(position.x)+","+str(position.y)+","+str(radius)
		output += ":\n\t0x"+fill.to_html(false)+",1:1,0x"+outline.to_html(false)
	elif type == blocktypes.CHECKPOINT || type == blocktypes.FLAG:
		output += str(position.x)+","+str(position.y)+",0"
	output += "|\n"
	return output
# save data into rbmp file
func save_data(file:FileAccess)->void:
	# TODO: reduce size to the following comments
	file.store_8(type)
	file.store_pascal_string(name)
	if type == blocktypes.POLYGON || type == blocktypes.CIRCLE:
		file.store_pascal_string(flags) # store_8
		file.store_float(mass)
		file.store_float(friction)
		file.store_float(restitution)
	if type == blocktypes.POLYGON: file.store_var(polygon)
	else: file.store_var(position) # store_float x2
	if type == blocktypes.CIRCLE: file.store_float(radius)
	if type == blocktypes.POLYGON || type == blocktypes.CIRCLE:
		file.store_var(fill) # store_24
		file.store_var(outline) # store_24
# load data from rbmp file
func load_data(file:FileAccess)->void:
	# TODO: reduce size to the following comments
	type = file.get_8()
	name = file.get_pascal_string()
	if type == blocktypes.POLYGON || type == blocktypes.CIRCLE:
		flags = file.get_pascal_string() # store_8
		mass = file.get_float()
		friction = file.get_float()
		restitution = file.get_float()
	if type == blocktypes.POLYGON: polygon = file.get_var()
	else: position = file.get_var() # store_float x2
	if type == blocktypes.CIRCLE: radius = file.get_float()
	if type == blocktypes.POLYGON || type == blocktypes.CIRCLE:
		fill = file.get_var() # store_32
		outline = file.get_var() # store_16 
