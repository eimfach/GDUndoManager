class_name GDUndoManager

var _operations: Array = []
var _redo_operations: Array = []
var _lock: int = NONE

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
			_operations.append(op)
			_redo_operations.resize(0)
		REDO:
			_operations.append(op)
		UNDO:
			_redo_operations.append(op)

func undo():
	_lock = UNDO
	var op = _operations.pop_back()
	
	if !op:
		return
		
	op.fn.callv(op.args)
		
	emit_signal("operation", "Undo " + op.action_name)
	_lock = NONE
	
func redo():
	_lock = REDO
	var op = _redo_operations.pop_back()
	if !op:
		return
		
	op.fn.callv(op.args)
	
	emit_signal("operation", "Redo " + op.action_name)
	_lock = NONE
	
class GDUndoOperation:
	var action_name: String = "Action"
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
