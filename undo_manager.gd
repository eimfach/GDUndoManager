class_name GDUndoManager

var operations: Array = []
var redo_operations: Array = []
var _lock: int = NONE
var _last_undo_name: String = ""

enum {
	NONE,
	UNDO,
	REDO,
}

signal operation
	
func register_action(fn: Callable, args: Array):
	var op: GDUndoOperation = GDUndoOperation.new()
	op.fn = fn
	op.args = args
	
	match _lock:
		NONE:
			operations.append(op)
			redo_operations.resize(0)
		REDO:
			operations.append(op)
		UNDO:
			redo_operations.append(op)

func undo():
	_lock = UNDO
	var op = operations.pop_back()

	if !op:
		return
		
	op.fn.callv(op.args)
	
	if op.action_name == "Unknown Action":
		op.action_name = _last_undo_name
	else:
		_last_undo_name = op.action_name
		
	emit_signal("operation", "Undo " + op.action_name)
	_lock = NONE
	
func redo():
	_lock = REDO
	var op = redo_operations.pop_back()
	if !op:
		return
	
	if op.action_name == "Unknown Action":
		op.action_name = _last_undo_name
	
	op.fn.callv(op.args)
	
	emit_signal("operation", "Redo " + op.action_name)
	_lock = NONE
	
class GDUndoOperation:
	var action_name: String = "Unknown Action"
	var fn: Callable
	var args: Array = []
	
	func duplicate() -> GDUndoOperation:
		var op = GDUndoOperation.new()
		op.action_name = action_name
		op.fn = fn
		var new_args = []
		for a in args:
			if a is Node:
				new_args.append(a.duplicate())
			else:
				new_args.append(a)
		op.args = new_args
		return op
