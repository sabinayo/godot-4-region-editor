@tool
extends EditorPlugin

signal file_dialog_dir_selected(dir: String)
signal file_dialog_file_selected(path: String)
signal file_dialog_files_selected(paths: PackedStringArray)


var region_editor: Control = null
var region_editor_btn: Button = null
var file_dialog_requester: NodePath = ^""
var file_dialog: EditorFileDialog = null

var inspector_plugin: EditorInspectorPlugin
var undo_redo: EditorUndoRedoManager


func _enter_tree() -> void:
	undo_redo = get_undo_redo()
	inspector_plugin = preload("scripts/inspector.gd").new(undo_redo)
	add_inspector_plugin(inspector_plugin)
	
	region_editor = preload("scenes/region_editor.tscn").instantiate() as Control
	region_editor.get_from_file_system.connect(get_from_file_system)
	
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
	
	file_dialog_dir_selected.connect(Callable(region_editor, &"_on_file_dialog_dir_selected"))
	file_dialog_file_selected.connect(Callable(region_editor, &"_on_file_dialog_file_selected"))
	file_dialog_files_selected.connect(Callable(region_editor, &"_on_file_dialog_files_selected"))
	
	file_dialog = EditorFileDialog.new()
	add_child(file_dialog)
	file_dialog.dir_selected.connect(_on_file_dialog_dir_selected)
	file_dialog.file_selected.connect(_on_file_dialog_file_selected)
	file_dialog.files_selected.connect(_on_file_dialog_files_selected)


func _exit_tree() -> void:
	remove_inspector_plugin(inspector_plugin)
	region_editor_btn.queue_free()
	remove_control_from_bottom_panel(region_editor)
	region_editor.queue_free()
	
	if file_dialog:
		file_dialog.queue_free()


func _on_texture_region_editor_requested(sprite: Sprite2D) -> void:
	inspector_plugin.editor_plugin_texture_region_retrieved.connect(
		func (edit_texture_region_func: Callable) -> void:
			edit_texture_region_func.call()
			
			# Retrieve TextureRegionEditor closure.
			undo_redo.history_changed.connect(
				func () -> void:
					region_editor.set_texture_region_as_edited(sprite)
			, CONNECT_ONE_SHOT)
	, CONNECT_ONE_SHOT)
	
	var last_edited_object: Object = EditorInterface.get_inspector().get_edited_object()
	EditorInterface.edit_node(sprite)
	inspector_plugin.retrieve_texture_region_editor()
	
	if last_edited_object is Node:
		EditorInterface.edit_node(last_edited_object)
	else:
		EditorInterface.edit_node(null)


func _on_resource_picker_requested(sprite: Sprite2D) -> void:
	inspector_plugin.editor_resource_picker_retrieved.connect(
		func (resource_picker: EditorResourcePicker) -> void:
			region_editor.editor_resource_picker_set(resource_picker)
			inspector_plugin.resource_picker_retrieval = false
	, CONNECT_ONE_SHOT)
	
	# Temporaly edit the sprite to let Inpector plugin retrieve the EditorRegionEditor
	# Then edit the last edited object (if one) in the inspector
	var last_edited_object: Object = EditorInterface.get_inspector().get_edited_object()
	inspector_plugin.resource_picker_retrieval = true
	EditorInterface.edit_node(sprite)
	inspector_plugin.retrieve_resource_picker()
	
	if last_edited_object is Node:
		EditorInterface.edit_node(last_edited_object)
	else:
		EditorInterface.edit_node(null)


func get_from_file_system(
	requester: NodePath,
	title: String, filters: PackedStringArray,
	file_mode: EditorFileDialog.FileMode,
	access: EditorFileDialog.Access = EditorFileDialog.ACCESS_RESOURCES
) -> void:
	file_dialog_requester = requester
	file_dialog.title = title
	file_dialog.access = access
	file_dialog.filters = filters
	file_dialog.file_mode = file_mode
	file_dialog.popup_file_dialog()


func _on_file_dialog_dir_selected(dir: String) -> void:
	file_dialog_dir_selected.emit(file_dialog_requester, dir)


func _on_file_dialog_file_selected(path: String) -> void:
	file_dialog_file_selected.emit(file_dialog_requester, path)


func _on_file_dialog_files_selected(paths: PackedStringArray) -> void:
	file_dialog_files_selected.emit(file_dialog_requester, paths)
