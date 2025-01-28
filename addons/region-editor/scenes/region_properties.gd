@tool
extends PanelContainer

## Used to display the Godot Texture Region Editor Node.
signal texture_region_editor_requested(sprite: Sprite2D, requester: NodePath)

var data: Dictionary = {}
var _temp_sprite: Sprite2D = Sprite2D.new()


func set_data(new: Dictionary) -> void:
	data = new
	_temp_sprite.region_enabled = true
	_temp_sprite.region_rect = data["region_rect"]


func _on_copy_rect_data_pressed() -> void:
	DisplayServer.clipboard_set(data["region_rect"])


func _on_name_text_changed(new_text: String) -> void:
	data["name"] = new_text


func _on_update_rect_pressed() -> void:
	_temp_sprite.texture = load(data["base_texture"])
	texture_region_editor_requested.emit(_temp_sprite, get_path())


func _on_region_editor_texture_region_edited(sprite: Sprite2D, requester: NodePath) -> void:
	if requester == get_path():
		data["region_rect"] = sprite.region_rect
