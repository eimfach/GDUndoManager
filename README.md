`register_action` - register an action using a Callable and its arguments

`undo` undo last operation

`redo` redo last operation

Example:

```
extends Node3D

var undo_manager: GDUndoManager = GDUndoManager.new()

func _ready() -> void:
	undo_manager.connect("operation", print)
	add_cube()

func _on_add_pressed() -> void:
	add_cube()

func _on_remove_pressed() -> void:
	remove_cube(%Cubes.get_child(-1))

func add_cube(cube: MeshInstance3D = null):
	if !cube:
		var c: MeshInstance3D = %Cube.duplicate()
		var mat := c.get_surface_override_material(0).duplicate()
		mat.albedo_color = Color(randf_range(0.1,1.0), randf_range(0.1,1.0), randf_range(0.1,1.0))
		c.set_surface_override_material(0, mat)
		%Cubes.add_child(c)
		c.global_position.y += %Cubes.get_child_count()
		cube = c
	else:
		%Cubes.add_child(cube)
	
	cube.show()
	undo_manager.register_action(remove_cube, [cube])

func remove_cube(c: MeshInstance3D):
	var cd := c.duplicate()
	c.free()
	undo_manager.register_action(add_cube, [cd])

func _on_undo_pressed() -> void:
	undo_manager.undo()

func _on_redo_pressed() -> void:
	undo_manager.redo()
```