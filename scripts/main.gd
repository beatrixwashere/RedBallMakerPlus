# ------------ main.gd ------------
# handles all functions in the tool
# ---------------------------------
extends Node
# constants
const listblock:PackedScene = preload("res://scenes/block/list_block.tscn")
const editblock:PackedScene = preload("res://scenes/block/edit_block.tscn")
const polydata:PackedScene = preload("res://scenes/block/polydata.tscn")
const circle:CompressedTexture2D = preload("res://images/circle.png")
const checkpoint:CompressedTexture2D = preload("res://images/checkpoint.png")
const flag:CompressedTexture2D = preload("res://images/flag.png")
const icon_polygon:CompressedTexture2D = preload("res://images/icons/icon_polygon.png")
const icon_circle:CompressedTexture2D = preload("res://images/icons/icon_circle.png")
const icon_checkpoint:CompressedTexture2D = preload("res://images/icons/icon_checkpoint.png")
const icon_flag:CompressedTexture2D = preload("res://images/icons/icon_flag.png")
# variables
var keybinds:Dictionary = {
	"move_up": KEY_W,
	"move_left": KEY_A,
	"move_down": KEY_S,
	"move_right": KEY_D,
	"zoom_out": KEY_Q,
	"zoom_in": KEY_E,
	"reset_view": KEY_Z,
	"new_polygon": KEY_1,
	"new_circle": KEY_2,
	"new_checkpoint": KEY_3,
	"new_flag": KEY_4 }
# level
var level_blocks:Dictionary
var level_nidx:int = 0
var level_selection:int = -1
# ui input
var is_moving_scene:bool = false
var is_awaiting_input:bool = false
var keybind_to_set:String
var keytext_to_update:Node
# setup the tool
func _ready()->void:
	# opens settings file
	if !FileAccess.file_exists("user://settings.rbmpc"): apply_settings()
	var settingsfile:FileAccess = FileAccess.open("user://settings.rbmpc",FileAccess.READ)
	# prepares keybind settings
	for i in keybinds.keys():
		keybinds[i] = settingsfile.get_32()
		var n_setkeybind:Node = editblock.instantiate()
		n_setkeybind.name = i
		n_setkeybind.get_node("text").text = i
		n_setkeybind.get_node("text").add_theme_font_size_override("font_size",20)
		n_setkeybind.get_node("edit").visible = false
		n_setkeybind.get_node("popup_edit").text = OS.get_keycode_string(keybinds[i])
		n_setkeybind.get_node("popup_edit").add_theme_font_size_override("font_size",20)
		n_setkeybind.get_node("popup_edit").visible = true
		var await_keybind:Callable = func await_keybind_func()->void:
			n_setkeybind.get_node("popup_edit").text = "awaiting input..."
			is_awaiting_input = true
			keybind_to_set = i
			keytext_to_update = n_setkeybind.get_node("popup_edit")
		n_setkeybind.get_node("popup_edit").connect("button_down",await_keybind)
		%settings/container/keylist.add_child(n_setkeybind)
	%settings/container/keylist.move_child(%settings/container/keylist.get_child(0), \
	%settings/container/keylist.get_child_count()-1)
# handles input
func _input(event:InputEvent)->void:
	# keyboard
	if event is InputEventKey:
		if is_awaiting_input:
			keybinds[keybind_to_set] = event.keycode
			keytext_to_update.text = OS.get_keycode_string(event.keycode)
			is_awaiting_input = false
		elif level_selection == -1:
			if event.keycode == keybinds["move_up"]: if event.is_pressed():
				%ui.position.y -= 30/$ui.zoom.x
			if event.keycode == keybinds["move_left"]: if event.is_pressed():
				%ui.position.x -= 30/$ui.zoom.x
			if event.keycode == keybinds["move_down"]: if event.is_pressed():
				%ui.position.y += 30/$ui.zoom.x
			if event.keycode == keybinds["move_right"]: if event.is_pressed():
				%ui.position.x += 30/$ui.zoom.x
			if event.keycode == keybinds["zoom_out"]:
				if event.is_pressed() && %ui.zoom.x < 4.99:
					%ui.zoom += Vector2(0.1,0.1)
					%ui.scale = Vector2(1,1)/%ui.zoom
					%ui/rbref.scale = %ui.zoom
			if event.keycode == keybinds["zoom_in"]:
				if event.is_pressed() && %ui.zoom.x > 0.11:
					%ui.zoom -= Vector2(0.1,0.1)
					%ui.scale = Vector2(1,1)/%ui.zoom
					%ui/rbref.scale = %ui.zoom
			if event.keycode == keybinds["reset_view"]:
				%ui.position = Vector2(0,0)
				%ui.zoom = Vector2(2,2)
				%ui.scale = Vector2(0.5,0.5)
				%ui/rbref.scale = Vector2(2,2)
			if event.keycode == keybinds["new_polygon"]:
				if event.is_pressed(): new_block(Block.blocktypes.POLYGON)
			if event.keycode == keybinds["new_circle"]:
				if event.is_pressed(): new_block(Block.blocktypes.CIRCLE)
			if event.keycode == keybinds["new_checkpoint"]:
				if event.is_pressed(): new_block(Block.blocktypes.CHECKPOINT)
			if event.keycode == keybinds["new_flag"]:
				if event.is_pressed(): new_block(Block.blocktypes.FLAG)
	# mouse buttons
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_MIDDLE:
				is_moving_scene = event.is_pressed()
			MOUSE_BUTTON_WHEEL_UP:
				if event.is_pressed() && %ui.zoom.x < 4.99:
					%ui.zoom += Vector2(0.1,0.1)
					%ui.scale = Vector2(1,1)/%ui.zoom
					%ui/rbref.scale = %ui.zoom
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.is_pressed() && %ui.zoom.x > 0.11:
					%ui.zoom -= Vector2(0.1,0.1)
					%ui.scale = Vector2(1,1)/%ui.zoom
					%ui/rbref.scale = %ui.zoom
	# mouse motion
	if event is InputEventMouseMotion:
		if is_moving_scene:
			%ui.position -= event.relative/%ui.zoom.x
	update_info()
# creates a new block in the level
func new_block(n_type:int)->void:
	# create and setup block data
	var n_data:Block = Block.new()
	n_data.name = str(level_nidx)
	n_data.type = n_type
	if n_data.type == Block.blocktypes.POLYGON:
		n_data.polygon.append(Vector2(0,0)+round(%ui.position))
		n_data.polygon.append(Vector2(50,0)+round(%ui.position))
		n_data.polygon.append(Vector2(50,50)+round(%ui.position))
		n_data.polygon.append(Vector2(0,50)+round(%ui.position))
	else:
		n_data.position = round(%ui.position)
		if n_data.type == Block.blocktypes.CHECKPOINT: n_data.position.y -= 21
		if n_data.type == Block.blocktypes.FLAG: n_data.position.y -= 46
	# add block to scene
	new_levelobj(n_data)
	# add block to list
	new_listobj(n_data)
	level_blocks[level_nidx] = n_data
	level_nidx += 1
# helper function for making the levelobj
func new_levelobj(bdata:Block)->void:
	match bdata.type:
		Block.blocktypes.POLYGON:
			var n_block_obj:Polygon2D = Polygon2D.new()
			n_block_obj.set_color(bdata.fill)
			n_block_obj.set_polygon(bdata.polygon)
			%level.add_child(n_block_obj)
			var n_block_outline:Line2D = Line2D.new()
			n_block_outline.points = bdata.polygon
			n_block_outline.closed = true
			n_block_outline.width = 2
			n_block_outline.default_color = bdata.outline
			n_block_obj.add_child(n_block_outline)
			bdata.levelobj = n_block_obj
		Block.blocktypes.CIRCLE:
			var n_block_obj:Sprite2D = Sprite2D.new()
			n_block_obj.texture = circle
			n_block_obj.position = bdata.position
			n_block_obj.scale = Vector2(bdata.radius/50,bdata.radius/50)
			n_block_obj.self_modulate = bdata.outline
			%level.add_child(n_block_obj)
			var n_block_fill:Sprite2D = Sprite2D.new()
			n_block_fill.texture = n_block_obj.texture
			n_block_fill.scale = Vector2(0.95,0.95)
			n_block_fill.self_modulate = bdata.fill
			n_block_obj.add_child(n_block_fill)
			bdata.levelobj = n_block_obj
		Block.blocktypes.CHECKPOINT:
			var n_block_obj:Sprite2D = Sprite2D.new()
			n_block_obj.texture = checkpoint
			n_block_obj.centered = false
			n_block_obj.position = bdata.position
			%level.add_child(n_block_obj)
			bdata.levelobj = n_block_obj
		Block.blocktypes.FLAG:
			var n_block_obj:Sprite2D = Sprite2D.new()
			n_block_obj.texture = flag
			n_block_obj.centered = false
			n_block_obj.position = bdata.position
			%level.add_child(n_block_obj)
			bdata.levelobj = n_block_obj
# helper function for making the listobj
func new_listobj(bdata:Block)->void:
	var n_block_list:Control = listblock.instantiate()
	n_block_list.name = str(level_nidx)
	match bdata.type:
		Block.blocktypes.POLYGON: n_block_list.get_node("icon").texture = icon_polygon
		Block.blocktypes.CIRCLE: n_block_list.get_node("icon").texture = icon_circle
		Block.blocktypes.CHECKPOINT: n_block_list.get_node("icon").texture = icon_checkpoint
		Block.blocktypes.FLAG: n_block_list.get_node("icon").texture = icon_flag
	n_block_list.get_node("text").text = bdata.name
	n_block_list.get_node("edit").connect("button_down", edit_block.bind(level_nidx))
	n_block_list.get_node("move_up").connect("button_down", move_block.bind(level_nidx, true))
	n_block_list.get_node("move_down").connect("button_down", move_block.bind(level_nidx, false))
	%blocklist.add_child(n_block_list)
	%blocklist.move_child(n_block_list, 0)
	bdata.listobj = n_block_list
# opens the block edit menu
func edit_block(idx:int)->void:
	close_edits()
	# helper function for new list
	var c_edit_obj:Callable = \
	func c_edit_obj_func(i_name:String, i_type:String, i_var:Variant, i_popup:String = "")->void:
		var n_edit_obj:Control = editblock.instantiate()
		n_edit_obj.name = i_name
		n_edit_obj.get_node("text").text = i_name
		n_edit_obj.get_node("edit").placeholder_text = i_type
		n_edit_obj.get_node("edit").text = str(i_var)
		if i_popup != "":
			n_edit_obj.get_node("edit").visible = false
			n_edit_obj.get_node("popup_edit").visible = true
			n_edit_obj.get_node("popup_edit").connect("button_down", \
			n_edit_obj.get_node(i_popup).set_visible.bind(true))
			match i_popup:
				"popup_color":
					n_edit_obj.get_node("popup_color/color").color = i_var
				"popup_polygon":
					var polylist:Node = n_edit_obj.get_node("popup_polygon/container/editlist")
					for i in i_var:
						var n_polydata:Node = polydata.instantiate()
						n_polydata.get_node("xcoord").text = str(i.x)
						n_polydata.get_node("ycoord").text = str(i.y)
						polylist.add_child(n_polydata)
					var add_polydata:Callable = func add_polydata_func()->void:
						var n_polydata:Node = polydata.instantiate()
						polylist.add_child(n_polydata)
						polylist.move_child(n_polydata, polylist.get_child_count()-3)
					polylist.move_child(polylist.get_child(0), polylist.get_child_count()-1)
					polylist.move_child(polylist.get_child(0), polylist.get_child_count()-1)
					polylist.get_node("addpoint/button").connect("button_down", add_polydata)
		else:
			n_edit_obj.get_node("popup_edit").queue_free()
			n_edit_obj.get_node("popup_color").queue_free()
			n_edit_obj.get_node("popup_polygon").queue_free()
		%editlist.add_child(n_edit_obj)
		%editlist.move_child(n_edit_obj, \
		%editlist.get_child_count()-2)
	# setup list
	# TODO: add rest of variables, especially polygon
	c_edit_obj.call("name","string",level_blocks[idx].name)
	if level_blocks[idx].type == Block.blocktypes.POLYGON || \
	level_blocks[idx].type == Block.blocktypes.CIRCLE:
		c_edit_obj.call("flags","string",level_blocks[idx].flags)
		c_edit_obj.call("mass","float",level_blocks[idx].mass)
		c_edit_obj.call("friction","float",level_blocks[idx].friction)
		c_edit_obj.call("restitution","float",level_blocks[idx].restitution)
	if level_blocks[idx].type == Block.blocktypes.POLYGON:
		c_edit_obj.call("polygon","",level_blocks[idx].polygon,"popup_polygon")
	else:
		c_edit_obj.call("x-position","int",level_blocks[idx].position.x)
		c_edit_obj.call("y-position","int",level_blocks[idx].position.y)
	if level_blocks[idx].type == Block.blocktypes.CIRCLE:
		c_edit_obj.call("radius","int",level_blocks[idx].radius)
	if level_blocks[idx].type == Block.blocktypes.POLYGON || \
	level_blocks[idx].type == Block.blocktypes.CIRCLE:
		c_edit_obj.call("fill","",level_blocks[idx].fill,"popup_color")
		c_edit_obj.call("outline","",level_blocks[idx].outline,"popup_color")
	# scene obj indicators
	level_blocks[idx].levelobj.modulate.a = 0.5
	level_selection = idx
# applies block edits
func apply_edits()->void:
	# set block data
	level_blocks[level_selection].name = %editlist.get_node("name/edit").text
	if level_blocks[level_selection].type == Block.blocktypes.POLYGON || \
	level_blocks[level_selection].type == Block.blocktypes.CIRCLE:
		level_blocks[level_selection].flags = %editlist.get_node("flags/edit").text
		level_blocks[level_selection].mass = %editlist.get_node("mass/edit").text.to_float()
		level_blocks[level_selection].friction = %editlist.get_node("friction/edit").text.to_float()
		level_blocks[level_selection].restitution = %editlist.get_node("restitution/edit").text.to_float()
		level_blocks[level_selection].fill = %editlist.get_node("fill/popup_color/color").color
		level_blocks[level_selection].outline = %editlist.get_node("outline/popup_color/color").color
	if level_blocks[level_selection].type == Block.blocktypes.POLYGON:
		level_blocks[level_selection].polygon = PackedVector2Array()
		for i in %editlist.get_node("polygon/popup_polygon/container/editlist").get_children():
			if i.name != "addpoint" && i.name != "scrollfix": \
			level_blocks[level_selection].polygon.append(Vector2( \
			i.get_node("xcoord").text.to_int(), i.get_node("ycoord").text.to_int()))
	else:
		level_blocks[level_selection].position.x = %editlist.get_node("x-position/edit").text.to_int()
		level_blocks[level_selection].position.y = %editlist.get_node("y-position/edit").text.to_int()
	if level_blocks[level_selection].type == Block.blocktypes.CIRCLE:
		level_blocks[level_selection].radius = %editlist.get_node("radius/edit").text.to_int()
	# apply data to scene
	if level_blocks[level_selection].type == Block.blocktypes.POLYGON:
		level_blocks[level_selection].levelobj.polygon = level_blocks[level_selection].polygon
		level_blocks[level_selection].levelobj.color = level_blocks[level_selection].fill
		level_blocks[level_selection].levelobj.get_child(0).points = level_blocks[level_selection].polygon
		level_blocks[level_selection].levelobj.get_child(0).default_color = level_blocks[level_selection].outline
	if level_blocks[level_selection].type == Block.blocktypes.CIRCLE:
		level_blocks[level_selection].levelobj.position = level_blocks[level_selection].position
		level_blocks[level_selection].levelobj.scale = Vector2( \
		level_blocks[level_selection].radius/50,level_blocks[level_selection].radius/50)
		level_blocks[level_selection].levelobj.self_modulate = level_blocks[level_selection].outline
		level_blocks[level_selection].levelobj.get_child(0).self_modulate = level_blocks[level_selection].fill
	if level_blocks[level_selection].type == Block.blocktypes.CHECKPOINT || \
	level_blocks[level_selection].type == Block.blocktypes.FLAG:
		level_blocks[level_selection].levelobj.position = level_blocks[level_selection].position
	close_edits()
# removes the edit list
func close_edits()->void:
	if level_selection != -1: level_blocks[level_selection].levelobj.modulate.a = 1
	for i in %editlist.get_children(): 
		%editlist.remove_child(i)
	%editlist.add_child(Control.new())
	level_selection = -1
# moves the block's z index
func move_block(idx:int, dir:bool)->void:
	# change the list child index
	if dir && level_blocks[idx].listobj.get_index()-1 >= 0:
		%blocklist.move_child(level_blocks[idx].listobj, level_blocks[idx].listobj.get_index()-1)
	elif !dir && level_blocks[idx].listobj.get_index()+1 <= %blocklist.get_child_count()-2:
		%blocklist.move_child(level_blocks[idx].listobj, level_blocks[idx].listobj.get_index()+1)
	# change the level child index
	if dir && level_blocks[idx].listobj.get_index()+1 <= %level.get_child_count()-1:
		%level.move_child(level_blocks[idx].levelobj, level_blocks[idx].levelobj.get_index()+1)
	elif !dir && level_blocks[idx].levelobj.get_index()-1 >= 0:
		%level.move_child(level_blocks[idx].levelobj, level_blocks[idx].levelobj.get_index()-1)
# deletes the selected block
func delete_block()->void:
	# remove data, levelobj, and listobj
	if level_selection != -1:
		for i in %editlist.get_children(): 
			i.queue_free()
		%editlist.add_child(Control.new())
		level_blocks[level_selection].levelobj.queue_free()
		level_blocks[level_selection].listobj.queue_free()
		level_blocks.erase(level_selection)
		level_selection = -1
# clears the entire level
func clear_level()->void:
	# clear data and scene
	level_blocks.clear()
	for i in %level.get_children(): i.queue_free()
	for i in %blocklist.get_children(): i.queue_free()
	for i in %editlist.get_children():  i.queue_free()
	# recreate death barrier
	var level_death:Line2D = Line2D.new()
	level_death.points = [Vector2(10000,585),Vector2(-10000,585)]
	level_death.width = 50
	level_death.default_color = Color(1,0,0,0.75)
	%level.add_child(level_death)
	# reset nidx
	level_nidx = 0
# updates the settings file
func apply_settings()->void:
	var settingsfile:FileAccess = FileAccess.open("user://settings.rbmpc",FileAccess.WRITE)
	for i in keybinds.values(): settingsfile.store_32(i)
# exports the level to a txt file
func export_level(filepath:String)->void:
	# generate level string
	var export_string:String = ""
	for i in %blocklist.get_children():
		if i.name != "scrollfix": export_string += level_blocks[i.name.to_int()].encode_level()
	# save file
	var levelfile:FileAccess = FileAccess.open(filepath, FileAccess.WRITE)
	levelfile.store_line(export_string)
# exports the level as an rbmp save
func export_save(filepath:String)->void:
	# save file
	var savefile:FileAccess = FileAccess.open(filepath, FileAccess.WRITE)
	savefile.store_32(level_blocks.size())
	for i in %blocklist.get_children():
		if i.name != "scrollfix": level_blocks[i.name.to_int()].save_data(savefile)
# imports the level from an rbmp save
func import_save(filepath:String)->void:
	# clear scene
	clear_level()
	# load file
	var savefile:FileAccess = FileAccess.open(filepath, FileAccess.READ)
	var level_size:int = savefile.get_32()
	for i in level_size:
		# load block data
		var n_data:Block = Block.new()
		n_data.load_data(savefile)
		# create levelobj
		new_levelobj(n_data)
		# create listobj
		new_listobj(n_data)
		level_blocks[level_nidx] = n_data
		level_nidx += 1
# updates row_info text
func update_info()->void:
	$ui/menus/row_info/position.text = "( "+str(round(%ui.position.x))+" , "+str(round(%ui.position.y))+" )"
	$ui/menus/row_info/zoom.text = str(snapped(%ui.zoom.x,0.1))+"x"
# closes the application
func exit_app()->void:
	get_tree().quit()
