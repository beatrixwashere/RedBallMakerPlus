# ------------ main.gd ------------
# handles all functions in the tool
# ---------------------------------
extends Node
#region variables
# level
var level_blocks:Array[Block]
# ui input
var is_moving_scene:bool = false
#endregion
# handles input
func _input(event:InputEvent)->void:
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
					update_info()
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.is_pressed() && %ui.zoom.x > 0.11:
					%ui.zoom -= Vector2(0.1,0.1)
					%ui.scale = Vector2(1,1)/%ui.zoom
					%ui/rbref.scale = %ui.zoom
					update_info()
	# mouse motion
	if event is InputEventMouseMotion:
		if is_moving_scene:
			%ui.position -= event.relative*%level.scale.x
			update_info()
# creates a new block in the level
func new_block()->void:
	# create and setup block data
	var n_data:Block = Block.new()
	n_data.name = str(level_blocks.size())
	n_data.polygon.append(Vector2(0,0)+(round(%ui.position)-Vector2(64,0)))
	n_data.polygon.append(Vector2(50,0)+(round(%ui.position)-Vector2(64,0)))
	n_data.polygon.append(Vector2(50,50)+(round(%ui.position)-Vector2(64,0)))
	n_data.polygon.append(Vector2(0,50)+(round(%ui.position)-Vector2(64,0)))
	level_blocks.append(n_data)
	# add block to scene
	var n_block_obj:Polygon2D = Polygon2D.new()
	n_block_obj.set_color(n_data.fill)
	n_block_obj.set_polygon(n_data.polygon)
	%level.add_child(n_block_obj)
	# add block to list
	var n_block_list:Control = load("res://scenes/objs/list_block.tscn").instantiate() as Control
	n_block_list.get_node("text").text = n_data.name
	%ui/menus/obj_list/container/list.add_child(n_block_list)
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
	for i in level_blocks:
		export_string += i.encode_level()
	# save file
	var levelfile:FileAccess = FileAccess.open(filepath, FileAccess.WRITE)
	levelfile.store_line(export_string)
# exports the level as an rbmp save
func export_save(filepath:String)->void:
	# save file
	var savefile:FileAccess = FileAccess.open(filepath, FileAccess.WRITE)
	savefile.store_32(level_blocks.size())
	for i in level_blocks:
		i.save_data(savefile)
	print("export_save "+filepath)
# imports the level from an rbmp save
func import_save(filepath:String)->void:
	# clear scene
	level_blocks.clear()
	for i in %level.get_children():
		i.queue_free()
	# load file
	var savefile:FileAccess = FileAccess.open(filepath, FileAccess.READ)
	var level_size:int = savefile.get_32()
	for i in level_size:
		var n_data:Block = Block.new()
		n_data.load_data(savefile)
		level_blocks.append(n_data)
	# generate scene
	for i in level_blocks:
		var n_block_obj:Polygon2D = Polygon2D.new()
		n_block_obj.set_color(i.fill)
		n_block_obj.set_polygon(i.polygon)
		%level.add_child(n_block_obj)
		var n_block_list:Control = load("res://scenes/objs/list_block.tscn").instantiate() as Control
		n_block_list.get_node("text").text = i.name
		%ui/menus/obj_list/container/list.add_child(n_block_list)
# updates row_info text
func update_info()->void:
	$ui/menus/row_info/position.text = "( "+str(round(%ui.position.x))+" , "+str(round(%ui.position.y))+" )"
