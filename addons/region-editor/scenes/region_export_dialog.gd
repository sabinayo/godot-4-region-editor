@tool
class_name RegionEditorRegionExportDialog

extends ConfirmationDialog

## Export Dialog used to export a Region.
## Queuefree once operation is canceled, succesful or not.[br]
## Add an instance to any node and activate it with the method 'set_image(image: TextureRect').

signal export_canceled()
signal export_successful(path: String)

const TRANSPARENT_COLOR: Color = Color("#ffffff00")
const VALID_IMAGES_EXTENSIONS_FOR_EXPORT: PackedStringArray = [
	"*.png", "*.jpg", "*.exr", "*.webp"
]

@export var ADVANCED_SETTINGS: Array[NodePath] = []

var _image_original_size: Vector2 = Vector2.ZERO
var _image_size_ratio: float = 1.0
var _updating_image_size: bool = false


func set_image(image: TextureRect) -> void:
	%Texture.texture = image.texture.duplicate()
	%Texture.modulate = image.modulate
	%Texture.material = image.material
	
	_image_original_size = image.texture.get_size()
	_image_size_ratio = _image_original_size.x / _image_original_size.y
	
	%TextureOriginalSize.text = """
	Original:
	W: %s px
	H: %s px
	""" % [
		_image_original_size.x,
		_image_original_size.y,
	]
	popup_centered()


func export(path: String) -> void:
	var export_size: Vector2 = _image_original_size
	var export_background_color: Color = TRANSPARENT_COLOR
	
	if not %UseTextureOriginalSize.button_pressed:
		export_size = Vector2(
			%TextureNewWidth.value,
			%TextureNewHeight.value
		)
	
	if not %UseTransparentBackground.button_pressed:
		export_background_color = %TextureBackgroundColorPicker.color
	
	$ExportViewport.size = export_size
	$ExportViewport/BackgrounColor.color = export_background_color
	$ExportViewport/Texture.texture = %Texture.texture
	
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var texture: ViewportTexture = $ExportViewport.get_texture()
	var image: Image = texture.get_image()
	var extension: String = path.get_extension()
	
	image.call(&"save_%s" % extension, path)
	export_successful.emit(path)
	queue_free()


func cancel_export() -> void:
	pass


func _on_use_transparent_background_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%TextureBackgroundColor.color = Color("#ffffff00")
	else:
		%TextureBackgroundColor.color = %TextureBackgroundColorPicker.color


func _on_texture_new_width_value_changed(value: float) -> void:
	if %UseTextureOriginalSize.button_pressed:
		%UseTextureOriginalSize.button_pressed = false
	
	if %LockUnlockRatio.button_pressed and not _updating_image_size:
		_updating_image_size = true
		%TextureNewHeight.value = value / _image_size_ratio
		_updating_image_size = false


func _on_texture_new_height_value_changed(value: float) -> void:
	if %UseTextureOriginalSize.button_pressed:
		%UseTextureOriginalSize.button_pressed = false
	
	if %LockUnlockRatio.button_pressed and not _updating_image_size:
		_updating_image_size = true
		%TextureNewWidth.value = value / _image_size_ratio
		_updating_image_size = false


func _on_lock_unlock_ratio_toggled(toggled_on: bool) -> void:
	_image_size_ratio = %TextureNewWidth.value / %TextureNewHeight.value


func _on_texture_background_color_picker_color_changed(color: Color) -> void:
	if %UseTransparentBackground.button_pressed:
		%UseTransparentBackground.button_pressed = false


func _on_advanced_settings_toggled(toggled_on: bool) -> void:
	for node_path: NodePath in ADVANCED_SETTINGS:
		get_node(node_path).visible = toggled_on
	
	_force_size_update()


#region Image Modifications
func _on_copy_image_pressed() -> void:
	pass # Replace with function body.


func _on_image_rotate_left_pressed() -> void:
	var image: Image = %Texture.texture.get_image()
	image.rotate_90(CLOCKWISE)
	%Texture.texture.set_image(image)


func _on_image_rotate_right_pressed() -> void:
	var image: Image = %Texture.texture.get_image()
	image.rotate_90(COUNTERCLOCKWISE)
	%Texture.texture.set_image(image)


func _on_image_flip_horizontal_pressed() -> void:
	var image: Image = %Texture.texture.get_image()
	image.flip_x()
	%Texture.texture.update(image)


func _on_image_flip_vertical_pressed() -> void:
	var image: Image = %Texture.texture.get_image()
	image.flip_y()
	%Texture.texture.update(image)


func _on_image_bcs_changed(value: float) -> void:
	var image: Image = %Texture.texture.get_image()
	image.adjust_bcs(%ImageBrightness.value, %ImageContrast.value, %ImageSaturation.value)
	%Texture.texture.update(image)


func _on_export_format_item_selected(index: int) -> void:
	_force_size_update()


func _force_size_update() -> void:
	size = Vector2(1.0, 1.0)
	child_controls_changed()


func _on_grab_folder_pressed() -> void:
	var file_dialog: EditorFileDialog = EditorFileDialog.new()
	add_child(file_dialog)
	file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	file_dialog.title = "Save Region Destination Folder"
	file_dialog.popup_file_dialog()
	file_dialog.dir_selected.connect(
		func (dir: String) -> void:
			%ExportFolder.tooltip_text = dir
			%ExportFolderLabel.text = dir
			file_dialog.queue_free()
	, CONNECT_ONE_SHOT)
	file_dialog.canceled.connect(
		func () -> void:
			file_dialog.queue_free()
	)


func _on_confirmed() -> void:
	if %AdvancedSettings.button_pressed:
		queue_free()
	else:
		var file_dialog: EditorFileDialog = EditorFileDialog.new()
		add_child(file_dialog)
		file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
		file_dialog.filters = VALID_IMAGES_EXTENSIONS_FOR_EXPORT
		file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
		file_dialog.title = "Save Region"
		file_dialog.current_file = "Region"
		file_dialog.popup_file_dialog()
		file_dialog.file_selected.connect(
			func (path: String) -> void:
				export(path)
		, CONNECT_ONE_SHOT)
		file_dialog.canceled.connect(
			func () -> void:
				file_dialog.queue_free()
		)

func _on_canceled() -> void:
	export_canceled.emit()
	queue_free()
