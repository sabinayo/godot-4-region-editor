@tool
extends Control

signal collision_point_updated(deleted: bool, point: Vector2, pos: Vector2)
signal selected(id: int, is_selected: bool)

var covered_area: Rect2
var collision_point: Vector2 = Vector2.ZERO
var handling_collision_point: bool = false
var snap_step: float = 2
var snap_offset: Vector2
var snap_type: RegionEditorCollisionEditor.SnapTypes = RegionEditorCollisionEditor.SnapTypes.GRID_SNAP
var action: RegionEditorCollisionEditor.Actions = RegionEditorCollisionEditor.Actions.ADD_COLLISION_POINTS


func _ready() -> void:
	set_process(false)
	_update_position(position)
	%Handler.tooltip_text = "id: %s" % get_index()


func get_used_rect() -> Rect2:
	return Rect2(
		global_position - Vector2(24, 24) / 2.0,
		Vector2(24, 24)
	)


func _process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	
	#if covered_area.has_point(mouse_position):
	var new_position: Vector2 = get_parent().to_local(mouse_position)
	_update_position(new_position)
	collision_point_updated.emit(get_index(), false, collision_point, global_position)


func _on_collision_editor_action_changed(new: RegionEditorCollisionEditor.Actions) -> void:
	action = new
	tooltip_text = "id: %s" % get_index()


func _on_snap_distance_changed(new: float) -> void:
	snap_step = new


func _on_snap_type_changed(new: RegionEditorCollisionEditor.SnapTypes) -> void:
	snap_type = new


func _on_handler_button_up() -> void:
	selected.emit(get_index(), false)
	handling_collision_point = false
	set_process(false)


func _on_handler_button_down() -> void:
	selected.emit(get_index(), true)
	
	match action:
		RegionEditorCollisionEditor.Actions.REMOVE_COLLISION_POINTS:
			collision_point_updated.emit(get_index(), true, collision_point, global_position)
			queue_free()
		
		RegionEditorCollisionEditor.Actions.EDIT_COLLISION_POINTS:
			handling_collision_point = true
			set_process(true)


func _update_position(to: Vector2) -> void:
	match snap_type:
		RegionEditorCollisionEditor.SnapTypes.NONE:
			position = to
		
		RegionEditorCollisionEditor.SnapTypes.HALF_PIXEL_SNAP:
			position = to.snappedf(snap_step)
		
		RegionEditorCollisionEditor.SnapTypes.GRID_SNAP:
			var snap: Vector2 = Vector2(snap_step, snap_step)
			var snapped_pos = (to - snap_offset).snapped(snap) + snap_offset
			position = snapped_pos#to.snappedf(snap_step + 20)
