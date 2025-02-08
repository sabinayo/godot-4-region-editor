extends TextureButton

signal collision_point_updated(deleted: bool, point: Vector2, pos: Vector2)
signal close_collision_polygon()

var covered_area: Rect2
var collision_point: Vector2 = Vector2.ZERO
var handling_collision_point: bool = false

var _action: RegionEditorCollisionEditor.Actions = RegionEditorCollisionEditor.Actions.NONE


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	
	if covered_area.has_point(mouse_position):
		position = get_parent().to_local(mouse_position)
		collision_point_updated.emit(get_index(), false, collision_point, global_position)


func _on_collision_editor_action_changed(action: RegionEditorCollisionEditor.Actions) -> void:
	_action = action


func _on_button_up() -> void:
	handling_collision_point = false
	set_process(false)


func _on_button_down() -> void:
	match _action:
		RegionEditorCollisionEditor.Actions.ADD_COLLISION_POINTS:
			close_collision_polygon.emit()
			return
		
		RegionEditorCollisionEditor.Actions.REMOVE_COLLISION_POINTS:
			collision_point_updated.emit(get_index(), true, collision_point, global_position)
			queue_free()
		
		RegionEditorCollisionEditor.Actions.EDIT_COLLISION_POINTS:
			handling_collision_point = true
			set_process(true)


func update_position(new: Vector2) -> void:
	position = Vector2(
		new.x - (new.x - size.x),
		new.y - (new.x - size.x)
	)
