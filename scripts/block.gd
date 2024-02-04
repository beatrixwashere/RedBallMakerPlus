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
