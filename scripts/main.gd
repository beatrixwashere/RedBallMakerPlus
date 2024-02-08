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
				%ui.position.y -= 15/$ui.zoom.x
			KEY_A:
				%ui.position.x -= 15/$ui.zoom.x
			KEY_S:
				%ui.position.y += 15/$ui.zoom.x
			KEY_D:
				%ui.position.x += 15/$ui.zoom.x
			KEY_Q:
				if %ui.zoom.x < 4.99:
					%ui.zoom += Vector2(0.1,0.1)
					%ui.scale = Vector2(1,1)/%ui.zoom
					%ui/rbref.scale = %ui.zoom
			KEY_E:
				if %ui.zoom.x > 0.11:
					%ui.zoom -= Vector2(0.1,0.1)
					%ui.scale = Vector2(1,1)/%ui.zoom
					%ui/rbref.scale = %ui.zoom
			KEY_Z:
				%ui.position = Vector2(0,0)
				%ui.zoom = Vector2(2,2)
				%ui.scale = Vector2(0.5,0.5)
				%ui/rbref.scale = Vector2(2,2)
			KEY_1:
				if event.is_pressed(): new_block()
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
func new_block()->void:
	# create and setup block data
	var n_data:Block = Block.new()
	n_data.name = str(level_nidx)
	n_data.polygon.append(Vector2(0,0)+round(%ui.position))
	n_data.polygon.append(Vector2(50,0)+round(%ui.position))
	n_data.polygon.append(Vector2(50,50)+round(%ui.position))
	n_data.polygon.append(Vector2(0,50)+round(%ui.position))
	# add block to scene
	var n_block_obj:Polygon2D = Polygon2D.new()
	n_block_obj.set_color(n_data.fill)
	n_block_obj.set_polygon(n_data.polygon)
	%level.add_child(n_block_obj)
	var n_block_outline:Line2D = Line2D.new()
	n_block_outline.points = n_data.polygon
	n_block_outline.closed = true
	n_block_outline.width = 2
	n_block_outline.default_color = n_data.outline
	n_block_obj.add_child(n_block_outline)
	n_data.levelobj = n_block_obj
	# add block to list
	var n_block_list:Control = load("res://scenes/block/list_block.tscn").instantiate() as Control
	n_block_list.get_node("text").text = n_data.name
	n_block_list.get_node("button").connect("button_down", edit_block.bind(level_nidx))
	%blocklist.add_child(n_block_list)
	%blocklist.move_child(n_block_list, \
	%blocklist.get_child_count()-2)
	n_data.listobj = n_block_list
	level_blocks[level_nidx] = n_data
	level_nidx += 1
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
	c_edit_obj.call("flags","string",level_blocks[idx].flags)
	c_edit_obj.call("mass","float",level_blocks[idx].mass)
	c_edit_obj.call("friction","float",level_blocks[idx].friction)
	c_edit_obj.call("restitution","float",level_blocks[idx].restitution)
	c_edit_obj.call("fill","",level_blocks[idx].fill,"popup_color")
	c_edit_obj.call("outline","",level_blocks[idx].outline,"popup_color")
	# scene obj indicators
	level_blocks[idx].levelobj.modulate = Color(1,1,1,0.5)
	level_selection = idx
# applies block edits
func apply_edits()->void:
	# set block data
	level_blocks[level_selection].name = %editlist.get_node("name/edit").text
	level_blocks[level_selection].flags = %editlist.get_node("flags/edit").text
	level_blocks[level_selection].mass = %editlist.get_node("mass/edit").text.to_float()
	level_blocks[level_selection].friction = %editlist.get_node("friction/edit").text.to_float()
	level_blocks[level_selection].restitution = %editlist.get_node("restitution/edit").text.to_float()
	level_blocks[level_selection].fill = %editlist.get_node("fill/popup_color/color").color
	level_blocks[level_selection].outline = %editlist.get_node("outline/popup_color/color").color
	# apply data to scene
	level_blocks[level_selection].levelobj.color = level_blocks[level_selection].fill
	level_blocks[level_selection].levelobj.get_child(0).default_color = level_blocks[level_selection].outline
	level_blocks[level_selection].listobj.get_node("text").text = level_blocks[level_selection].name
	close_edits()
# removes the edit list
func close_edits()->void:
	if level_selection != -1: level_blocks[level_selection].levelobj.modulate = Color(1,1,1,1)
	for i in %editlist.get_children(): 
		%editlist.remove_child(i)
	%editlist.add_child(Control.new())
	level_selection = -1
# opens level export file dialog
func select_file(option:String)->void:
	match option:
		"e_level": 
			%files.connect("file_selected", export_level)
			%files.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		"e_save": 
			%files.connect("file_selected", export_save)
			%files.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		"i_save": 
			%files.connect("file_selected", import_save)
			%files.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	%files.visible = true
# exports the level to a txt file
func export_level(filepath:String)->void:
	# generate level string
	var export_string:String = ""
	for i in level_blocks.values():
		export_string += i.encode_level()
	# save file
	var levelfile:FileAccess = FileAccess.open(filepath, FileAccess.WRITE)
	levelfile.store_line(export_string)
# exports the level as an rbmp save
func export_save(filepath:String)->void:
	# save file
	var savefile:FileAccess = FileAccess.open(filepath, FileAccess.WRITE)
	savefile.store_32(level_blocks.size())
	for i in level_blocks.values():
		i.save_data(savefile)
	print("export_save "+filepath)
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
		var n_data:Block = Block.new()
		n_data.load_data(savefile)
		var n_block_obj:Polygon2D = Polygon2D.new()
		n_block_obj.set_color(n_data.fill)
		n_block_obj.set_polygon(n_data.polygon)
		%level.add_child(n_block_obj)
		n_data.levelobj = n_block_obj
		var n_block_outline:Line2D = Line2D.new()
		n_block_outline.points = n_data.polygon
		n_block_outline.closed = true
		n_block_outline.width = 2
		n_block_outline.default_color = n_data.outline
		n_block_obj.add_child(n_block_outline)
		var n_block_list:Control = load("res://scenes/block/list_block.tscn").instantiate() as Control
		n_block_list.get_node("text").text = n_data.name
		%blocklist.add_child(n_block_list)
		%blocklist.move_child(n_block_list, \
		%blocklist.get_child_count()-2)
		n_data.listobj = n_block_list
		level_blocks[level_nidx] = n_data
		level_nidx += 1
# updates row_info text
func update_info()->void:
	$ui/menus/row_info/position.text = "( "+str(round(%ui.position.x))+" , "+str(round(%ui.position.y))+" )"
# closes the application
func exit_app()->void:
	get_tree().quit()
