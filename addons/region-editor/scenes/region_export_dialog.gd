@tool
extends ConfirmationDialog

const TRANSPARENT_COLOR: Color = Color("#ffffff00")
const VALID_IMAGES_EXTENSIONS_FOR_EXPORT: PackedStringArray = [
	"*.png", "*.jpg", "*.exr", "*.webp"
]

var _image_original_size: Vector2 = Vector2.ZERO
var _image_size_ratio: float = 1.0
var _updating_image_size: bool = false


func set_image(image: TextureRect) -> void:
	%Texture.texture = image.texture
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
