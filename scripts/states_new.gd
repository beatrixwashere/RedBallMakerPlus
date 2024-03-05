# ------------- states.gd --------------
# stores tool states for undoing/redoing
# --------------------------------------
# TODO: implement redos and optimize to single actions instead of level reloading
extends Node
# variables
var undo:Array[Array]
var redo:Array[String]
var idx:int = 0
# add new undo state
func add_undo(udata:Array)->void:
	undo.append(udata)
# undo an action
func load_undo()->void:
	if undo.size() > 0:
		var udata:Array = undo.pop_back()
		match udata[0]:
			"apply_edits":
				get_tree().current_scene.level_blocks[udata[3]] = udata[1]
				get_tree().current_scene.level_blocks[udata[3]].levelobj = udata[2]
			"move_block": pass
			_: pass
		var target:String = undo.pop_back()
		get_tree().current_scene.import_save(target)
		for i in 3: DirAccess.remove_absolute(undo.pop_back())
		#redo.append(target)
# redo an action
func load_redo()->void:
	if redo.size() > 0:
		var target:String = redo.pop_back()
		get_tree().current_scene.import_save(target)
		DirAccess.remove_absolute(undo.pop_back())
		undo.append(target)
# clear undo/redo list and files
func clear_list(list:Array)->void:
	for i in list: DirAccess.remove_absolute(i)
	list.clear()
