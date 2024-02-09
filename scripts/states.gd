# ------------- states.gd --------------
# stores tool states for undoing/redoing
# --------------------------------------
# TODO: finish and use
extends Node
# variables
var undo:Array[PackedScene]
var queue:PackedScene
var push:Timer
# add new undo state
func add_undo()->void:
	queue = PackedScene.new()
	wait_undo()
	await push.timeout
	queue.pack(get_tree().current_scene)
	undo.append(queue)
func wait_undo()->void:
	push.stop()
	push.start(0.5)
	pass
