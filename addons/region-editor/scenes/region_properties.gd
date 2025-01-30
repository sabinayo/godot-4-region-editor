@tool
extends PanelContainer

## Used to display the Godot Texture Region Editor Node.
signal file_system_requested(
	requester: NodePath,
	title: String, filters: PackedStringArray,
	file_mode: EditorFileDialog.FileMode,
	access: EditorFileDialog.Access)
signal texture_region_editor_requested(sprite: Sprite2D, requester: NodePath)
signal property_updated(data: Dictionary)

const VALID_IMAGES_EXTENSIONS_FOR_EXPORT: PackedStringArray = [
	"*.png", "*.jpg", "*.exr", "*.webp",
]

@export var _hidden_on_multiple_edition: Array[NodePath]

var _data: Dictionary = {}
var _edited_regions_data: Array[Dictionary] = []
var _multiple_edition: bool = false:
	set(value):
		_multiple_edition = value
		
		for node_path: NodePath in _hidden_on_multiple_edition:
			get_node(node_path).visible = not _multiple_edition

var _temp_sprite: Sprite2D = Sprite2D.new()
var _updating: bool = false


func set_data(new: Dictionary) -> void:
	_updating = true
	_data = new
	%Name.text = _data["name"]
	_temp_sprite.region_enabled = true
	_temp_sprite.region_rect = _data["region_rect"]
	%Modulate.color = _data["modulate"]
	%CopyRectData.tooltip_text = var_to_str(_data["region_rect"])
	%CopyResourcePath.tooltip_text = _data["base_texture"]
	_update_preview()
	_updating = false


func edit_multiple_regions(edit: bool, datas: Array[Dictionary]) -> void:
	_multiple_edition = edit
	_edited_regions_data = datas


func _on_copy_rect_data_pressed() -> void:
	DisplayServer.clipboard_set(var_to_str(_data["region_rect"]))


func _on_copy_resource_path_pressed() -> void:
	DisplayServer.clipboard_set(_data["base_texture"])


func _on_copy_image_pressed() -> void:
	DisplayServer.clipboard_set(var_to_str(%Preview.texture.get_image()))


func _on_name_text_changed(new_text: String) -> void:
	if new_text.is_valid_filename():
		_data["name"] = new_text
		property_updated.emit(_data.duplicate())


func _on_name_text_submitted(new_text: String) -> void:
	return
	if not new_text.is_valid_filename():
		%Name.text = _data["name"]
	else:
		property_updated.emit(_data.duplicate())


func _on_update_rect_pressed() -> void:
	_temp_sprite.texture = load(_data["base_texture"])
	texture_region_editor_requested.emit(_temp_sprite, get_path())


func _on_region_editor_texture_region_edited(sprite: Sprite2D, requester: NodePath) -> void:
	if requester == get_path():
		_data["region_rect"] = sprite.region_rect
		%CopyRectData.tooltip_text = var_to_str(_data["region_rect"])
		property_updated.emit(_data.duplicate())
		_update_preview()


func _update_preview() -> void:
	var image: Image = load(_data["base_texture"]).get_image()
	%Preview.texture = ImageTexture.create_from_image(image.get_region(_data["region_rect"]))
	%Preview.modulate = _data["modulate"]


func _on_modulate_color_changed(color: Color) -> void:
	if _updating: return
	
	_data["modulate"] = color
	%Preview.modulate = color
	property_updated.emit(_data.duplicate())


func _on_export_pressed() -> void:
	if _multiple_edition:
		%RegionsExportDialog.set_data(_edited_regions_data)
		%ExportDialog.popup_centered()
	else:
		%ExportSingleRegion.popup_centered()


func _on_export_dialog_canceled() -> void:
	%RegionsExportDialog.cancel_export()


func _on_export_dialog_confirmed() -> void:
	file_system_requested.emit(
		get_path(), "Save Image",
		VALID_IMAGES_EXTENSIONS_FOR_EXPORT,
		EditorFileDialog.FileMode.FILE_MODE_SAVE_FILE,
		EditorFileDialog.Access.ACCESS_FILESYSTEM,
	)
	%RegionsExportDialog.export()


func _on_region_editor_file_dialog_file_selected(requester: NodePath, path: String) -> void:
	if requester != get_path():
		return
	
	%viewport.size_2d_override = %Preview.size
	await RenderingServer.frame_post_draw
	var t = %viewport.get_texture()
	var image: Image = t.get_image()
	var extension: String = path.get_extension()
	
	if "*." + extension in VALID_IMAGES_EXTENSIONS_FOR_EXPORT:
		image.call(&"save_%s" % extension, path)
