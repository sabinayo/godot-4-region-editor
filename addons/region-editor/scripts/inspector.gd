@tool
extends EditorInspectorPlugin

signal editor_plugin_texture_region_retrieved()
signal editor_resource_picker_retrieved()

var texture_region_tracker: Control
var resource_picker_detector: Control
var property_for_resource_picker_retrieval: String = ""


func _can_handle(object: Object) -> bool:
	return object is Sprite2D or object is Resource


func _parse_property(
	object: Object, type: Variant.Type, name: String,
	hint_type: PropertyHint, hint_string: String,
	usage_flags: int, wide: bool
) -> bool:
	if name == property_for_resource_picker_retrieval:
		resource_picker_detector = Control.new()
		add_custom_control(resource_picker_detector)
		resource_picker_detector.hide()
	
	return false


func _parse_group(object: Object, group: String) -> void:
	if group == "Region":
		texture_region_tracker = Control.new()
		add_custom_control(texture_region_tracker)
		texture_region_tracker.hide()


## Used by the plugin to get the Godot EditorPluginTextureRegion
func retrieve_texture_region_editor() -> void:
	# Get the "Edit Region" Button
	var vbox: VBoxContainer = texture_region_tracker.get_parent()
	#vbox.print_tree_pretty()# Uncomment to see the node tree
	var edit_region_btn = vbox.get_child(-2)
	
	# Pass the callable to the plugin.
	var edit_texture_region_func: Callable = edit_region_btn.get_signal_connection_list(&"pressed")[0]["callable"]
	var texture_region_editor: Object = edit_texture_region_func.get_object()
	editor_plugin_texture_region_retrieved.emit(edit_texture_region_func)


func retrieve_resource_picker() -> void:
	if not property_for_resource_picker_retrieval:
		return
	
	var parent = resource_picker_detector.get_parent()
	#parent.print_tree_pretty()# Uncomment to the the node tree
	var resource_picker: EditorResourcePicker = parent.get_child(1).get_child(0)
	editor_resource_picker_retrieved.emit(resource_picker.duplicate(0))
	resource_picker_detector.queue_free()
	property_for_resource_picker_retrieval = ""
