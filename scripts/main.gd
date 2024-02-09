# ------------ main.gd ------------
# handles all functions in the tool
# ---------------------------------
extends Node
#region variables
# level
var level_blocks:Dictionary
var level_nidx:int = 0
var level_selection:int = -1
# ui input
var is_moving_scene:bool = false
#endregion
# handles input
func _input(event:InputEvent)->void:
	# keyboard
	if event is InputEventKey && level_selection == -1:
		match event.keycode:
			KEY_W:
				if event.is_pressed(): %ui.position.y -= 30/$ui.zoom.x
			KEY_A:
				if event.is_pressed(): %ui.position.x -= 30/$ui.zoom.x
			KEY_S:
				if event.is_pressed(): %ui.position.y += 30/$ui.zoom.x
			KEY_D:
				if event.is_pressed(): %ui.position.x += 30/$ui.zoom.x
			KEY_Q:
				if event.is_pressed() && %ui.zoom.x < 4.99:
					%ui.zoom += Vector2(0.1,0.1)
					%ui.scale = Vector2(1,1)/%ui.zoom
					%ui/rbref.scale = %ui.zoom
			KEY_E:
				if event.is_pressed() && %ui.zoom.x > 0.11:
					%ui.zoom -= Vector2(0.1,0.1)
					%ui.scale = Vector2(1,1)/%ui.zoom
					%ui/rbref.scale = %ui.zoom
			KEY_Z:
				%ui.position = Vector2(0,0)
				%ui.zoom = Vector2(2,2)
				%ui.scale = Vector2(0.5,0.5)
				%ui/rbref.scale = Vector2(2,2)
			KEY_1:
				if event.is_pressed(): new_block(Block.blocktypes.POLYGON)
			KEY_2:
				if event.is_pressed(): new_block(Block.blocktypes.CIRCLE)
			KEY_3:
				if event.is_pressed(): new_block(Block.blocktypes.CHECKPOINT)
			KEY_4:
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
			n_block_obj.texture = load("res://images/circle.png") as CompressedTexture2D
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
			n_block_obj.texture = load("res://images/checkpoint.png") as CompressedTexture2D
			n_block_obj.centered = false
			n_block_obj.position = bdata.position
			%level.add_child(n_block_obj)
			bdata.levelobj = n_block_obj
		Block.blocktypes.FLAG:
			var n_block_obj:Sprite2D = Sprite2D.new()
			n_block_obj.texture = load("res://images/flag.png") as CompressedTexture2D
			n_block_obj.centered = false
			n_block_obj.position = bdata.position
			%level.add_child(n_block_obj)
			bdata.levelobj = n_block_obj
# helper function for making the listobj
func new_listobj(bdata:Block)->void:
	var n_block_list:Control = load("res://scenes/block/list_block.tscn").instantiate() as Control
	n_block_list.name = str(level_nidx)
	match bdata.type:
		Block.blocktypes.POLYGON: n_block_list.get_node("icon").texture = \
		load("res://images/icons/icon_polygon.png") as CompressedTexture2D
		Block.blocktypes.CIRCLE: n_block_list.get_node("icon").texture = \
		load("res://images/icons/icon_circle.png") as CompressedTexture2D
		Block.blocktypes.CHECKPOINT: n_block_list.get_node("icon").texture = \
		load("res://images/icons/icon_checkpoint.png") as CompressedTexture2D
		Block.blocktypes.FLAG: n_block_list.get_node("icon").texture = \
		load("res://images/icons/icon_flag.png") as CompressedTexture2D
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
		var n_edit_obj:Control = load("res://scenes/block/edit_block.tscn").instantiate() as Control
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
					pass
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
	# apply data to scene
	if level_blocks[level_selection].type == Block.blocktypes.POLYGON:
		level_blocks[level_selection].levelobj.color = level_blocks[level_selection].fill
		level_blocks[level_selection].levelobj.get_child(0).default_color = level_blocks[level_selection].outline
	if level_blocks[level_selection].type == Block.blocktypes.CIRCLE:
		level_blocks[level_selection].levelobj.self_modulate = level_blocks[level_selection].outline
		level_blocks[level_selection].levelobj.get_child(0).self_modulate = level_blocks[level_selection].fill
	level_blocks[level_selection].listobj.get_node("text").text = level_blocks[level_selection].name
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
			%editlist.remove_child(i)
		%editlist.add_child(Control.new())
		level_blocks[level_selection].levelobj.queue_free()
		level_blocks[level_selection].listobj.queue_free()
		level_blocks.erase(level_selection)
		level_selection = -1
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
	level_blocks.clear()
	for i in %level.get_children():
		i.queue_free()
	level_nidx = 0
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
# closes the application
func exit_app()->void:
	get_tree().quit()
