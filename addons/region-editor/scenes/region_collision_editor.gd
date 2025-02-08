#@tool
class_name RegionEditorCollisionEditor

extends VBoxContainer

signal action_changed(new: Actions)

enum Actions {
	NONE,
	ADD_COLLISION_POINTS,
	EDIT_COLLISION_POINTS,
	REMOVE_COLLISION_POINTS,
}

const COLLISION_POINT_HANDLER: PackedScene = preload("collision_point_handler.tscn") as PackedScene

var action: Actions = Actions.NONE:
	set(value):
		action = value
		action_changed.emit(action)


func _ready() -> void:
	%Options.get_popup().index_pressed.connect(_on_options_index_pressed)
	%CollisionLine.position = %Preview.position


func _on_options_index_pressed(idx: int) -> void:
	var text: String = %Options.get_popup().get_item_text(idx)
	
	match text:
		"Clear":
			for child in %CollisionPointHandlers.get_children():
				child.queue_free()
			
			%CollisionLine.clear_points()


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
		if %EditorView.get_global_rect().has_point(event.position):
			match action:
				Actions.ADD_COLLISION_POINTS:
					var point: Vector2 = %CollisionLine.to_local(event.global_position)
					
					var point_handler = COLLISION_POINT_HANDLER.instantiate()
					%CollisionPointHandlers.add_child(point_handler)
					point_handler.update_position(%CollisionPointHandlers.to_local(event.global_position))
					point_handler.covered_area = %EditorView.get_global_rect()
					point_handler.collision_point = point
					point_handler._action == Actions.ADD_COLLISION_POINTS
					%CollisionLine.add_point(point)
					
					action_changed.connect(point_handler._on_collision_editor_action_changed)
					point_handler.collision_point_updated.connect(_on_collision_point_updated)
					point_handler.close_collision_polygon.connect(_on_close_collision_polygon)
					


func _on_add_collision_point_pressed() -> void:
	action = Actions.ADD_COLLISION_POINTS


func _on_edit_collision_point_pressed() -> void:
	action = Actions.EDIT_COLLISION_POINTS


func _on_remove_collision_point_pressed() -> void:
	action = Actions.REMOVE_COLLISION_POINTS


func _on_collision_point_updated(handler_id: int, deleted: bool, point: Vector2, point_position: Vector2) -> void:
	var point_idx: int = %CollisionLine.points.find(point)
	
	
	if deleted:
		%CollisionLine.remove_point(point_idx)
	else:
		var local_point_position: Vector2 = %CollisionLine.to_local(point_position)
		%CollisionLine.set_point_position(point_idx, local_point_position)
		
		var handler = %CollisionPointHandlers.get_child(handler_id)
		handler.collision_point = local_point_position


func _on_close_collision_polygon() -> void:
	%CollisionLine.closed = true
