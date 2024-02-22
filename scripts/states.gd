# ------------- states.gd --------------
# stores tool states for undoing/redoing
# --------------------------------------
# TODO: implement redos and optimize to single actions instead of level reloading
extends Node
# variables
var undo:Array[String]
var redo:Array[String]
var idx:int = 0
# add new undo state
func add_undo()->void:
	var target:String = "user://tempstate_"+str(idx)+".rbmp"
	get_tree().current_scene.export_save(target)
	undo.append(target)
	idx += 1
# undo an action
func load_undo()->void:
	if undo.size() > 0:
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
