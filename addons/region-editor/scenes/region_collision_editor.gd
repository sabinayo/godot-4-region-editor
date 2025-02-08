@tool
class_name RegionEditorCollisionEditor

extends VBoxContainer

signal distraction_free_changed(enabled: bool)
signal action_changed(new: Actions)
signal snap_distance_changed(new: float)
signal snap_type_changed(type: SnapTypes)

enum Actions {
	NONE,
	ADD_COLLISION_POINTS,
	EDIT_COLLISION_POINTS,
	REMOVE_COLLISION_POINTS,
}

enum SnapTypes {
	NONE,
	HALF_PIXEL_SNAP,
	GRID_SNAP,
}

const COLLISION_POINT_HANDLER: PackedScene = preload("collision_point_handler.tscn") as PackedScene


var first_point_rect: Rect2
var action: Actions = Actions.NONE:
	set(value):
		action = value
		action_changed.emit(action)

var snap_type: SnapTypes = SnapTypes.NONE:
	set(value):
		snap_type = value
		snap_type_changed.emit(snap_type)


func _ready() -> void:
	%Options.get_popup().index_pressed.connect(_on_options_index_pressed)


func set_texture_preview(preview: TextureRect) -> void:
	%Preview.texture = preview.texture
	%Preview.texture_filter = preview.mouse_filter
	%Preview.texture_repeat = preview.texture_repeat
	%Preview.modulate = preview.modulate
	%Preview.size = %Preview.texture.get_image().get_size()


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
		if (
			%EditorView.get_global_rect().has_point(event.position)
			and not (%EditorView.get_menu_hbox().get_global_rect().has_point(event.position))
		):
			match action:
				Actions.ADD_COLLISION_POINTS:
					var point: Vector2 = %CollisionLine.to_local(event.global_position)
					
					if closing_polygon:
						%CollisionLine.closed = true
						%CollisionLine.default_color = Color.RED
						closing_polygon = false
						return
					
					var point_handler = COLLISION_POINT_HANDLER.instantiate()
					point_handler.position = %CollisionPointHandlers.to_local(event.global_position)
					point_handler.covered_area = %EditorView.get_global_rect()
					point_handler.snap_type = snap_type
					point_handler.snap_step = %GridSnap.value
					point_handler.collision_point = point
					point_handler.snap_offset = Vector2(56, 141)
					point_handler.action == Actions.ADD_COLLISION_POINTS
					%CollisionPointHandlers.add_child(point_handler)
					%CollisionLine.add_point(point)
					
					snap_type_changed.connect(point_handler._on_snap_type_changed)
					snap_distance_changed.connect(point_handler._on_snap_distance_changed)
					action_changed.connect(point_handler._on_collision_editor_action_changed)
					point_handler.selected.connect(_on_collision_point_handler_selected)
					point_handler.collision_point_updated.connect(_on_collision_point_updated)
					point_handler.close_collision_polygon.connect(_on_close_collision_polygon)


func _on_add_collision_point_pressed() -> void:
	action = Actions.ADD_COLLISION_POINTS


func _on_edit_collision_point_pressed() -> void:
	action = Actions.EDIT_COLLISION_POINTS


func _on_remove_collision_point_pressed() -> void:
	action = Actions.REMOVE_COLLISION_POINTS

var closing_polygon: bool = false

func _on_collision_point_handler_selected(id: int, is_selected: bool) -> void:
	if id == 0 and is_selected and %CollisionLine.points.size() >= 2:
		closing_polygon = true
		set_process_input(false)
		%CollisionLine.closed = true
		%CollisionLine.default_color = Color.RED
		set_process_input(true)

func _on_collision_point_updated(handler_id: int, deleted: bool, point: Vector2, point_position: Vector2) -> void:
	var point_idx: int = %CollisionLine.points.find(point)
	
	
	if deleted:
		%CollisionLine.remove_point(point_idx)
	else:
		var local_point_position: Vector2 = %CollisionLine.to_local(point_position)
		%CollisionLine.set_point_position(point_idx, local_point_position)
		
		var handler = %CollisionPointHandlers.get_child(handler_id)
		handler.collision_point = local_point_position


func close_polygon() -> void:
	pass


func _on_close_collision_polygon() -> void:
	pass
	#%CollisionLine.closed = true


func is_point_on_segment(point: Vector2, a: Vector2, b: Vector2) -> bool:
	# Vérifie si le point est colinéaire au segment
	var cross_product = (point - a).cross(b - a)
	if abs(cross_product) > 0.00001:
		return false  # Pas colinéaire, donc pas sur le segment
	
	# Vérifie si le point est dans les limites du segment
	var dot_product = (point - a).dot(b - a)
	if dot_product < 0:
		return false  # Le point est en dehors du segment du côté de A
	
	var squared_length = (b - a).length_squared()
	if dot_product > squared_length:
		return false  # Le point est en dehors du segment du côté de B
	
	return true  # Le point est colinéaire et dans les limites du segment


func _on_snap_options_item_selected(index: int) -> void:
	match index:
		0:
			%GridSnap.hide()
			%EditorView.show_grid = false
			snap_type = SnapTypes.NONE
		
		1:
			%GridSnap.hide()
			%EditorView.show_grid = true
			snap_type = SnapTypes.HALF_PIXEL_SNAP
		
		2:
			%GridSnap.show()
			%EditorView.show_grid = true
			snap_type = SnapTypes.GRID_SNAP


func _on_grid_snap_value_changed(value: float) -> void:
	%EditorView.snapping_distance = value
	snap_distance_changed.emit(value)


func _on_distraction_free_toggled(toggled_on: bool) -> void:
	distraction_free_changed.emit(toggled_on)
