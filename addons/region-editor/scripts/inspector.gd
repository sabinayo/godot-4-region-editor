@tool
extends EditorInspectorPlugin

signal editor_plugin_texture_region_retrieved()
signal editor_resource_picker_retrieved()

var undo_redo: EditorUndoRedoManager
var rect_editor_enabler: CheckBox
var resource_picker_detector: Control
var resource_picker_retrieval: bool = false


func _init(editor_undo_redo_manager: EditorUndoRedoManager) -> void:
	undo_redo = editor_undo_redo_manager


func _can_handle(object: Object) -> bool:
	return object is Sprite2D or object is Resource


func _parse_property(
	object: Object, type: Variant.Type, name: String,
	hint_type: PropertyHint, hint_string: String,
	usage_flags: int, wide: bool
) -> bool:
	if name == "texture" and resource_picker_retrieval:
		resource_picker_detector = Control.new()
		add_custom_control(resource_picker_detector)
		resource_picker_detector.hide()
	
	return false


func _parse_group(object: Object, group: String) -> void:
	#var sprite := object as Sprite2D
	
	if group == "Region":
		rect_editor_enabler = CheckBox.new()
		rect_editor_enabler.text = "Autorect"
		
		rect_editor_enabler.toggled.connect(
			func (toogled_on: bool) -> void:
				pass
				#if toogled_on:
					#undo_redo.create_action("Sprite2D Rect Editor: Autorect", UndoRedo.MERGE_ENDS)
					#undo_redo.add_do_property(sprite, "region_enabled", true)
					#undo_redo.add_undo_property(sprite, "region_enabled", sprite.region_enabled)
					#undo_redo.add_do_property(sprite, "region_rect", desired_rect)
					#undo_redo.add_undo_property(sprite, "region_rect", sprite.region_rect)
					#undo_redo.commit_action()
		)
		add_custom_control(rect_editor_enabler)


## Used by the plugin to get the Godot EditorPluginTextureRegion
func retrieve_texture_region_editor() -> void:
	# Get the "Edit Region" Button
	var vbox: VBoxContainer = rect_editor_enabler.get_parent()
	#vbox.print_tree_pretty()# Uncomment to see the node tree
	var edit_region_btn = vbox.get_child(-2)
	
	# Pass the callable to the plugin.
	var edit_texture_region_func: Callable = edit_region_btn.get_signal_connection_list(&"pressed")[0]["callable"]
	var texture_region_editor: Object = edit_texture_region_func.get_object()
	editor_plugin_texture_region_retrieved.emit(edit_texture_region_func)


func retrieve_resource_picker() -> void:
	if not resource_picker_retrieval:
		return
	
	var parent = resource_picker_detector.get_parent()
	#parent.print_tree_pretty()# Uncomment to the the node tree
	var resource_picker: EditorResourcePicker = parent.get_child(1).get_child(0)
	editor_resource_picker_retrieved.emit(resource_picker.duplicate())
	resource_picker_detector.queue_free()
