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
	output += typestr[type]+"_"+name+","
	# behavior
	if type == blocktypes.POLYGON || type == blocktypes.CIRCLE:
		output += flags+","+str(snapped(mass,0.001))+","+str(snapped(friction,0.001))+","+str(snapped(restitution,0.001))
	elif type == blocktypes.CHECKPOINT || type == blocktypes.FLAG:
		output += "b_ground"
	# shape & color
	output += ":"+shapestr[type]+","
	if type == blocktypes.POLYGON:
		for i in polygon: output += str(i.x)+","+str(i.y)+","
		output = output.erase(output.length()-1)
		output += ":0x"+fill.to_html(false)+",1:1,0x"+outline.to_html(false)
	if type == blocktypes.CIRCLE:
		output += str(position.x)+","+str(position.y)+","+str(snapped(radius,0.001))
		output += ":0x"+fill.to_html(false)+",1:1,0x"+outline.to_html(false)
	elif type == blocktypes.CHECKPOINT || type == blocktypes.FLAG:
		output += str(position.x)+","+str(position.y)+",0"
	output += "|"
	return output
# decode from level format
func decode_level(ldata:String)->void:
	# trim unnecessary data
	ldata = ldata.erase(0,2)
	if ldata.find("1:1,") != -1: ldata = ldata.erase(ldata.find("1:1,"),4)
	# organize data
	var properties:PackedStringArray
	var typepos:PackedStringArray
	var colors:PackedStringArray
	var fulldata:PackedStringArray = ldata.split(":")
	properties = fulldata[0].split(",")
	typepos = fulldata[1].split(",")
	# get block type
	match typepos[0]:
		"p": type = blocktypes.POLYGON
		"c": type = blocktypes.CIRCLE
		"cp": type = blocktypes.CHECKPOINT
		"la": type = blocktypes.FLAG
	# get properties
	name = properties[0]
	if type == blocktypes.POLYGON || type == blocktypes.CIRCLE:
		flags = properties[1]
		mass = float(properties[2])
		friction = float(properties[3])
		restitution = float(properties[4])
	# get position
	if type == blocktypes.POLYGON: for i in int((typepos.size()-1)/2.0):
		polygon.append(Vector2(int(typepos[2*i+1]),int(typepos[2*i+2])))
	else:
		position.x = int(typepos[1])
		position.y = int(typepos[2])
		if type == blocktypes.CIRCLE: radius = float(typepos[3])
	# get colors
	if type == blocktypes.POLYGON || type == blocktypes.CIRCLE:
		colors = fulldata[2].split(",")
		fill = Color.from_string(colors[0].substr(2),Color(0,0,0,1))
		outline = Color.from_string(colors[1].substr(2),Color(0,0,0,1))
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
		mass = snapped(file.get_float(),0.001)
		friction = snapped(file.get_float(),0.001)
		restitution = snapped(file.get_float(),0.001)
	if type == blocktypes.POLYGON: polygon = file.get_var()
	else: position = file.get_var() # store_float x2
	if type == blocktypes.CIRCLE: radius = snapped(file.get_float(),0.001)
	if type == blocktypes.POLYGON || type == blocktypes.CIRCLE:
		fill = file.get_var() # store_32
		outline = file.get_var() # store_16
# get average position of polygon data
func get_polyavg()->Vector2:
	var result:Vector2 = Vector2()
	for i in polygon: result += i
	result /= polygon.size()
	return result
