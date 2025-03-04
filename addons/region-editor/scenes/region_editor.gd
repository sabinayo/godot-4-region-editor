@tool
extends PanelContainer

## Only used by the plugin.
signal resource_picker_requested(sprite: Sprite2D, property: String)
signal resource_picker_retrieved(resource_picker: EditorResourcePicker, requester: NodePath)
## Only used by the plugin.
signal texture_region_editor_requested(sprite: Sprite2D)
signal texture_region_edited(sprite: Sprite2D, requester: NodePath)


var edited_region_id: int = -1
var editing_multiple_regions: bool = false

var _resource_picker_requester: NodePath = ^""
var _texture_region_editor_requester: NodePath = ^""


#region Texture
func _on_add_texture() -> void:
	# Parse image recognized extensions
	var recognized_extensions: PackedStringArray = ResourceLoader.get_recognized_extensions_for_type("Image")
	var extensions: PackedStringArray = []
	
	for extension in recognized_extensions:
		extensions.append("*.%s" % extension)
	
	var file_dialog: EditorFileDialog = EditorFileDialog.new()
	add_child(file_dialog)
	file_dialog.filters = extensions
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILES
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.popup_file_dialog()
	file_dialog.files_selected.connect(
		func (paths: PackedStringArray) -> void:
			%TextureContainer.add_textures(paths)
			file_dialog.queue_free()
	, CONNECT_ONE_SHOT)
	file_dialog.canceled.connect(
		func () -> void:
			file_dialog.queue_free()
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
	_update_texture_fast_options(data)
	%TextureInfos.show()


func _on_texture_container_textures_requested() -> void:
	_on_add_texture()


func _on_texture_container_empty_container() -> void:
	%TextureEditor.hide()
	%ToggleTexturesDock.hide()
	%SortTextures.hide()
	%DeleteTexture.hide()
	%TexturesOptions.alignment = HBoxContainer.ALIGNMENT_CENTER
	%TextureInfos.hide()


func _on_texture_container_texture_deleted() -> void:
	%TextureEditor.hide()
	%TextureInfos.hide()
	%ToggleTexturesDock.hide()


func _on_texture_container_texture_added() -> void:
	%TexturesFastOptions.visible = %TextureContainer.textures_count > 1


func _update_texture_fast_options(data: Dictionary) -> void:
	var texture_name: String = data.get("texture_name", %TextureName.text)
	var texture_path: String = data.get("texture_path", %TexturePath.tooltip_text)
	
	%TextureName.text = texture_name
	%TextureName.tooltip_text = %TextureName.text
	%TexturePath.text = texture_path.replace("res://", "")
	%TexturePath.tooltip_text = texture_path


func _on_texture_path_pressed() -> void:
	DisplayServer.clipboard_set(%TexturePath.tooltip_text)


func _on_texture_region_editor_requested(sprite: Sprite2D, requester: NodePath) -> void:
	_texture_region_editor_requester = requester
	texture_region_editor_requested.emit(sprite)


func _on_toggle_textures_dock_toggled(toggled_on: bool) -> void:
	%TexturesDock.visible = not toggled_on


func _on_toggle_texture_setup_dock_toggled(toggled_on: bool) -> void:
	%TextureSetup.visible = not toggled_on
	%TextureSetupFastActions.visible = toggled_on


func _on_texture_setup_texture_data_updated(data: Dictionary) -> void:
	var incoming_modulate: Color = data.get("modulate", %ChangeTextureModulate.color)
	
	if %ChangeTextureModulate.color != incoming_modulate:
		%RegionPreviewerContainer.set_data_from_texture_setup(data)
	
	%ChangeTextureModulate.color = incoming_modulate
	%ChangeTextureSelfModulate.color = data.get("self_modulate", %ChangeTextureSelfModulate.color)
	
	_update_texture_fast_options(data)


func _on_change_texture_modulate(color: Color) -> void:
	%RegionPreviewerContainer.set_data_from_texture_setup({
		"modulate": color
	})

#endregion

#region TexturesRegions

func _on_all_regions_selection_requested(selected: bool) -> void:
	if not selected and editing_multiple_regions:
		%RegionPropertiesDock.hide()


func _on_edit_multiple_regions_pressed() -> void:
	editing_multiple_regions = true
	%RegionPropertiesLabel.text = "Regions Properties"
	%RegionProperties.edit_multiple_regions(
		true,
		%RegionPreviewerContainer.get_selected_regions_data(),
		%ChangeTextureModulate.color
	)
	%RegionPropertiesDock.show()


func set_texture_region_as_edited(sprite: Sprite2D) -> void:
	texture_region_edited.emit(sprite, _texture_region_editor_requester)
	
	if _texture_region_editor_requester == %TextureSetup.get_path():
		if sprite.has_meta(&"new_region"):
			var create_region: bool = sprite.get_meta(&"new_region")
			
			if create_region:
				sprite.set_meta(&"new_region", false)
				%RegionPreviewerContainer.add_region_from(sprite)
			else:
				%RegionPreviewerContainer.update_region_data({
					"id": %RegionPreviewerContainer.region_count -1,
					"region_rect": sprite.region_rect,
				})
	
	#_texture_region_editor_requester = ^""


func _on_region_previewer_container_region_deleted(was_edited: bool, region_id: int) -> void:
	if (
		region_id == edited_region_id
		or (
			editing_multiple_regions
			and %RegionPreviewerContainer.selected_regions.size() < 2
		)
	):
		%RegionPropertiesDock.hide()


func _on_region_previewer_container_region_edition_requested(data: Dictionary) -> void:
	edited_region_id = data["id"]
	editing_multiple_regions = false
	%RegionPropertiesLabel.text = "Region Properties"
	%RegionPropertiesDock.show()
	%RegionProperties.edit_multiple_regions(false, [] as Array[Dictionary], Color.WHITE)
	%RegionProperties.set_data(data)


func _on_region_previewer_container_region_updated(data: Dictionary) -> void:
	if data["id"] == edited_region_id and %RegionPropertiesDock.visible:
		%RegionProperties.set_data(data)

#endregion

#region Utils
func _on_resource_picker_requested(sprite: Sprite2D, property: String, requester: NodePath) -> void:
	_resource_picker_requester = requester
	resource_picker_requested.emit(sprite, property)


func editor_resource_picker_set(node: EditorResourcePicker) -> void:
	resource_picker_retrieved.emit(node, _resource_picker_requester)
	_resource_picker_requester = ^""

#endregion
