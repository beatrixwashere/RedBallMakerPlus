# --- block.gd ----
# stores block data
# -----------------
extends Resource
class_name Block
# data
var type:String = "b"
var name:String = "0"
var behavior:String = "n"
var mass:float = 0
var friction:float = 1
var restitution:float = 0.2
var shape:String = "p"
var polygon:PackedVector2Array = PackedVector2Array()
var fill:Color = Color(0,0,0,1)
# TODO: add textures
var outline:Color = Color(0,0,0,1)
# encode into level format
func encode_level()->String:
	var output:String = ""
	output += type+"_"+name+","+behavior+","+str(mass)+","+str(friction)+","+str(restitution)+":"+shape+","
	for i in polygon: output += str(i.x)+","+str(i.y)+","
	output = output.erase(output.length()-1)
	output += ":0x"+fill.to_html(false)+",1:1,0x"+outline.to_html(false)+"|"
	return output
# save data into rbmp file
func save_data(file:FileAccess)->void:
	# TODO: reduce size to the following comments
	file.store_pascal_string(type) # store_8
	file.store_pascal_string(name)
	file.store_pascal_string(behavior) # store_8
	file.store_float(mass)
	file.store_float(friction)
	file.store_float(restitution)
	file.store_pascal_string(shape) # store_8
	file.store_var(polygon)
	file.store_var(fill) # store_32
	file.store_var(outline) # store_16 
# load data from rbmp file
func load_data(file:FileAccess)->void:
	# TODO: reduce size to the following comments
	type = file.get_pascal_string() # store_8
	name = file.get_pascal_string()
	behavior = file.get_pascal_string() # store_8
	mass = file.get_float()
	friction = file.get_float()
	restitution = file.get_float()
	shape = file.get_pascal_string() # store_8
	polygon = file.get_var()
	fill = file.get_var() # store_32
	outline = file.get_var() # store_16 
