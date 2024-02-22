# --- layer.gd ----
# stores layer data
# -----------------
extends Resource
class_name Layer
# data
var name:String = ""
var visible:bool = true
var blocks:Array[Block]
var blklist:Node
var levelobj:Node
var listobj:Node
# stores the layer blocks
func store_layer(lvlblks:Dictionary)->void:
	blocks.clear()
	for i in blklist.get_children(): if i.name != "scrollfix":
		blocks.append(lvlblks[i.name.to_int()])
# encode into level format
func encode_level()->void:
	for i in blocks: i.encode_level()
# save data into rbmp file
func save_data(file:FileAccess)->void:
	file.store_pascal_string(name)
	file.store_32(blocks.size())
	file.store_8(int(visible))
	for i in blocks: i.save_data(file)
# load data from rbmp file
func load_data(file:FileAccess)->void:
	name = file.get_pascal_string()
	var bsize:int = file.get_32()
	visible = bool(file.get_8())
	for i in bsize:
		var nblock:Block = Block.new()
		nblock.load_data(file)
		blocks.append(nblock)
