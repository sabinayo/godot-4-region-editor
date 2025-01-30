@tool
extends PanelContainer

## Used to display the Godot Texture Region Editor Node.
signal texture_region_editor_requested(sprite: Sprite2D, requester: NodePath)
signal property_updated(data: Dictionary)

var data: Dictionary = {}

var _temp_sprite: Sprite2D = Sprite2D.new()
var _updating: bool = false


func set_data(new: Dictionary) -> void:
	_updating = true
	data = new
	%Name.text = data["name"]
	_temp_sprite.region_enabled = true
	_temp_sprite.region_rect = data["region_rect"]
	%Modulate.color = data["modulate"]
	%CopyRectData.tooltip_text = var_to_str(data["region_rect"])
	%CopyResourcePath.tooltip_text = data["base_texture"]
	_update_preview()
	_updating = false


func _on_copy_rect_data_pressed() -> void:
	DisplayServer.clipboard_set(var_to_str(data["region_rect"]))


func _on_copy_resource_path_pressed() -> void:
	DisplayServer.clipboard_set(data["base_texture"])


func _on_copy_image_pressed() -> void:
	DisplayServer.clipboard_set(var_to_str(%Preview.texture))


func _on_name_text_changed(new_text: String) -> void:
	if new_text.is_valid_filename():
		data["name"] = new_text
		property_updated.emit(data.duplicate())


func _on_name_text_submitted(new_text: String) -> void:
	return
	if not new_text.is_valid_filename():
		%Name.text = data["name"]
	else:
		property_updated.emit(data.duplicate())


func _on_update_rect_pressed() -> void:
	_temp_sprite.texture = load(data["base_texture"])
	texture_region_editor_requested.emit(_temp_sprite, get_path())


func _on_region_editor_texture_region_edited(sprite: Sprite2D, requester: NodePath) -> void:
	if requester == get_path():
		data["region_rect"] = sprite.region_rect
		%CopyRectData.tooltip_text = var_to_str(data["region_rect"])
		property_updated.emit(data.duplicate())
		_update_preview()


func _update_preview() -> void:
	var image: Image = load(data["base_texture"]).get_image()
	%Preview.texture = ImageTexture.create_from_image(image.get_region(data["region_rect"]))
	%Preview.modulate = data["modulate"]


func _on_modulate_color_changed(color: Color) -> void:
	if _updating: return
	
	data["modulate"] = color
	%Preview.modulate = color
	property_updated.emit(data.duplicate())
