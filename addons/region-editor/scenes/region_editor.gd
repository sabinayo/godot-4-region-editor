@tool
extends PanelContainer

signal get_from_file_system(
	requester: NodePath,
	title: String, filters: PackedStringArray,
	file_mode: EditorFileDialog.FileMode,
	access: EditorFileDialog.Access
)

## Only used by the plugin.
signal resource_picker_requested(sprite: Sprite2D, property: String)
signal resource_picker_retrieved(resource_picker: EditorResourcePicker, requester: NodePath)
## Only used by the plugin.
signal texture_region_editor_requested(sprite: Sprite2D)
signal texture_region_edited(sprite: Sprite2D, requester: NodePath)

signal file_dialog_dir_selected(dir: String)
signal file_dialog_file_selected(path: String)
signal file_dialog_files_selected(paths: PackedStringArray)

## Used to know for which purpose file/dir/files are picked.
enum FileSystemActions {
	NONE,
	ADDING_TEXTURES,
}


var edited_region_id: int = -1

var _file_sytem_action: FileSystemActions = FileSystemActions.NONE
var _resource_picker_requester: NodePath = ^""
var _texture_region_editor_requester: NodePath = ^""


func request_file_system(
	requester: NodePath,
	title: String, filters: PackedStringArray,
	file_mode: EditorFileDialog.FileMode,
	access: EditorFileDialog.Access
) -> void:
	get_from_file_system.emit(requester, title, filters, file_mode, access)


func _on_add_texture() -> void:
	_file_sytem_action = FileSystemActions.ADDING_TEXTURES
	
	# Parse image recognized extensions
	var recognized_extensions: PackedStringArray = ResourceLoader.get_recognized_extensions_for_type("Image")
	var extensions: PackedStringArray = []
	
	for extension: String in recognized_extensions:
		extensions.append("*.%s" % extension)
	
	request_file_system(
		get_path(), "",
		extensions,
		EditorFileDialog.FileMode.FILE_MODE_OPEN_FILES,
		EditorFileDialog.Access.ACCESS_RESOURCES,
	)


func _on_delete_texture() -> void:
	%TextureContainer.delete_selected_texture()


func _on_sort_item_selected(index: int) -> void:
	pass


func _on_texture_container_texture_selected(data: Dictionary) -> void:
	%TextureEditor.show()
	%ToggleTexturesDock.show()
	%SortTextures.show()
	%DeleteTexture.show()
	%TexturesOptions.alignment = HBoxContainer.ALIGNMENT_END


func _on_texture_container_textures_requested() -> void:
	_on_add_texture()


func _on_texture_container_empty_container() -> void:
	%TextureEditor.hide()
	%ToggleTexturesDock.hide()
	%SortTextures.hide()
	%DeleteTexture.hide()
	%TexturesOptions.alignment = HBoxContainer.ALIGNMENT_CENTER


func _on_texture_container_texture_deleted() -> void:
	%TextureEditor.hide()
	%ToggleTexturesDock.hide()


func _on_texture_container_texture_added() -> void:
	pass


func _on_texture_region_editor_requested(sprite: Sprite2D, requester: NodePath) -> void:
	_texture_region_editor_requester = requester
	texture_region_editor_requested.emit(sprite)


func set_texture_region_as_edited(sprite: Sprite2D) -> void:
	texture_region_edited.emit(sprite, _texture_region_editor_requester)
	
	if _texture_region_editor_requester == %TextureSetup.get_path():
		%RegionPreviewerContainer.add_region_from(sprite)
		_update_regions_numb()
	
	_texture_region_editor_requester = ^""


func _on_resource_picker_requested(sprite: Sprite2D, property: String, requester: NodePath) -> void:
	_resource_picker_requester = requester
	resource_picker_requested.emit(sprite, property)


func editor_resource_picker_set(node: EditorResourcePicker) -> void:
	resource_picker_retrieved.emit(node, _resource_picker_requester)
	_resource_picker_requester = ^""


func _on_region_previewer_container_region_selected(is_selected: bool, region_id: int) -> void:
	_update_regions_numb()


func _update_regions_numb() -> void:
	# Regions numb
	%RegionsLabel.text = "Regions: %s" % %RegionPreviewerContainer.region_count 
	
	# Selected regions
	var selected_regions: int = %RegionPreviewerContainer.selected_regions
	
	%SelectedRegionsLabel.visible = selected_regions > 0
	%SelectedRegionsLabel.text = "%s / %s" % [
		selected_regions,
		%RegionPreviewerContainer.region_count
	]


func _on_region_previewer_container_region_deleted(was_edited: bool, region_id: int) -> void:
	_update_regions_numb()
	
	if region_id == edited_region_id:
		%RegionPropertiesDock.hide()


func _on_region_previewer_container_region_edition_requested(data: Dictionary) -> void:
	edited_region_id = data["id"]
	%RegionPropertiesDock.show()
	%RegionProperties.set_data(data)


func _on_region_previewer_container_region_updated(data: Dictionary) -> void:
	if data["id"] == edited_region_id and %RegionPropertiesDock.visible:
		%RegionProperties.set_data(data)


func _on_file_dialog_dir_selected(requester: NodePath, dir: String) -> void:
	file_dialog_dir_selected.emit(requester, dir)
	
	if requester != get_path():
		_file_sytem_action = FileSystemActions.NONE
		return


func _on_file_dialog_file_selected(requester: NodePath, path: String) -> void:
	file_dialog_file_selected.emit(requester, path)
	
	if requester != get_path():
		_file_sytem_action = FileSystemActions.NONE
		return


func _on_file_dialog_files_selected(requester: NodePath, paths: PackedStringArray) -> void:
	file_dialog_files_selected.emit(requester, paths)
	
	if requester != get_path():
		_file_sytem_action = FileSystemActions.NONE
		return
	
	match _file_sytem_action:
		FileSystemActions.ADDING_TEXTURES:
			%TextureContainer.add_textures(paths)
	
	_file_sytem_action = FileSystemActions.NONE


func _on_toggle_textures_dock_toggled(toggled_on: bool) -> void:
	%TexturesDock.visible = not toggled_on


func _on_toggle_texture_setup_dock_toggled(toggled_on: bool) -> void:
	%TextureSetup.visible = not toggled_on
	%TextureSetupFastActions.visible = toggled_on


func _on_texture_setup_texture_data_updated(data: Dictionary) -> void:
	if %ChangeTextureModulate.color != data["modulate"]:
		%RegionPreviewerContainer.set_data_from_texture_setup(data)
	
	%ChangeTextureModulate.color = data["modulate"]
	%ChangeTextureSelfModulate.color = data["self_modulate"]


func _on_change_texture_modulate(color: Color) -> void:
	%RegionPreviewerContainer.set_data_from_texture_setup({
		"modulate": color
	})
