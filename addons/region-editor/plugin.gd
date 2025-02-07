@tool
extends EditorPlugin


enum DragStates {
	NONE,
	RIGHT,
	LEFT,
	TOP,
	BOTTOM,
}

const HANDLE_OFFSET: float = 8.0
const GDRID_SIZE: float = 8.0

var region_editor: Control = null
var region_editor_btn: Button = null

var inspector_plugin: EditorInspectorPlugin
var undo_redo: EditorUndoRedoManager

var img_handle_right: Texture2D = preload("icons/handle_right.svg") as Texture2D
var img_handle_bottom: Texture2D = preload("icons/handle_bottom.svg") as Texture2D
var img_handle_left: Texture2D = preload("icons/handle_left.svg") as Texture2D
var img_handle_top: Texture2D = preload("icons/handle_top.svg") as Texture2D

var current_object: Sprite2D
var drag_state := DragStates.NONE
var starting_mouse_pos_in_scene: Vector2
var starting_current_object_global_rect: Rect2
var starting_current_object_region_rect: Rect2
var starting_current_object_global_pos: Vector2


func _enter_tree() -> void:
	undo_redo = get_undo_redo()
	inspector_plugin = preload("scripts/inspector.gd").new(undo_redo)
	add_inspector_plugin(inspector_plugin)
	
	region_editor = preload("scenes/region_editor.tscn").instantiate() as Control
	region_editor.resource_picker_requested.connect(_on_resource_picker_requested)
	region_editor.texture_region_editor_requested.connect(_on_texture_region_editor_requested)
	
	# Add Shortcut
	var shortcut: Shortcut = Shortcut.new()
	var key: InputEventKey = InputEventKey.new()
	key.keycode = KEY_R
	key.alt_pressed = true
	shortcut.events = [key]
	
	region_editor_btn = add_control_to_bottom_panel(region_editor, "Region Editor", shortcut)
	region_editor_btn.tooltip_text = "Toggle Region Editor Bottom Panel"


func _exit_tree() -> void:
	remove_inspector_plugin(inspector_plugin)
	region_editor_btn.queue_free()
	remove_control_from_bottom_panel(region_editor)
	region_editor.queue_free()



func _on_texture_region_editor_requested(sprite: Sprite2D) -> void:
	inspector_plugin.editor_plugin_texture_region_retrieved.connect(
		func (edit_texture_region_func: Callable) -> void:
			# Retrieve TextureRegionEditor closure.
			edit_texture_region_func.call()
			
			undo_redo.history_changed.connect(
				func () -> void:
					var texture_region_editor: Object = edit_texture_region_func.get_object()
					var undo_redo_id: int = undo_redo.get_object_history_id(texture_region_editor)
					
					if undo_redo.get_history_undo_redo(0).get_action_name(0) == &"Set Region Rect":
						region_editor.set_texture_region_as_edited(sprite)
			)
	, CONNECT_ONE_SHOT)
	
	var last_edited_object: Object = EditorInterface.get_inspector().get_edited_object()
	EditorInterface.edit_node(sprite)
	inspector_plugin.retrieve_texture_region_editor()
	
	if last_edited_object is Node:
		EditorInterface.edit_node(last_edited_object)
	else:
		EditorInterface.edit_node(null)


func _on_resource_picker_requested(sprite: Sprite2D, property: String) -> void:
	inspector_plugin.editor_resource_picker_retrieved.connect(
		func (resource_picker: EditorResourcePicker) -> void:
			region_editor.editor_resource_picker_set(resource_picker)
	, CONNECT_ONE_SHOT)
	
	# Temporaly edit the sprite to let Inpector plugin retrieve the EditorRegionEditor
	# Then edit the last edited object (if one) in the inspector
	var last_edited_object: Object = EditorInterface.get_inspector().get_edited_object()
	inspector_plugin.property_for_resource_picker_retrieval = property
	EditorInterface.edit_node(sprite)
	inspector_plugin.retrieve_resource_picker()
	
	if last_edited_object is Node:
		EditorInterface.edit_node(last_edited_object)
	else:
		EditorInterface.edit_node(null)
