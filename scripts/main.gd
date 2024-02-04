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
					%ui/rbref.scale = %ui.zoom*2
					update_info()
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.is_pressed() && %ui.zoom.x > 0.11:
					%ui.zoom -= Vector2(0.1,0.1)
					%ui.scale = Vector2(1,1)/%ui.zoom
					%ui/rbref.scale = %ui.zoom*2
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
	level_blocks.append(n_data)
	n_data.polygon.append(Vector2(0,0)+round(%ui.position))
	n_data.polygon.append(Vector2(50,0)+round(%ui.position))
	n_data.polygon.append(Vector2(50,50)+round(%ui.position))
	n_data.polygon.append(Vector2(0,50)+round(%ui.position))
	# add block to scene
	var n_block_obj:Polygon2D = Polygon2D.new()
	n_block_obj.set_color(Color(0,0,0,1))
	n_block_obj.set_polygon(n_data.polygon)
	%level.add_child(n_block_obj)
# opens level export file dialog
func select_export_file()->void:
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
# updates row_info text
func update_info()->void:
	$ui/menus/row_info/position.text = "( "+str(round(%ui.position.x))+" , "+str(round(%ui.position.y))+" )"
