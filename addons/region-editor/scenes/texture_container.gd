@tool
extends PanelContainer

signal empty_container()
signal textures_requested()
signal texture_selected(data: Dictionary)
signal texture_deleted()

var _editable_texture: PackedScene = preload("editable_texture.tscn")

var selected_texture: int = -1
var recognized_extensions: PackedStringArray = ResourceLoader.get_recognized_extensions_for_type("Image")


func delete_selected_texture() -> void:
	if selected_texture != -1:
		%Container.get_child(selected_texture).queue_free()
		texture_deleted.emit()
		
		if %Container.get_child_count() == 0:
			empty_container.emit()
			%AddTextures.show()


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data.get("type", "") == "files"


func _drop_data(at_position: Vector2, data: Variant) -> void:
	add_textures(data["files"])


func add_textures(files: PackedStringArray) -> void:
	for file_path: String in files:
		if not (file_path.get_extension() in recognized_extensions):
			continue
		
		var texture: Texture2D = load(file_path) as Texture2D
		var texture_name: String = file_path.get_file()
		
		var editable_texture: RegionEditorEditableTexture = _editable_texture.instantiate()
		%Container.add_child(editable_texture)
		editable_texture.owner = owner
		editable_texture.selected.connect(_on_editable_texture_selected)
		editable_texture.icon = texture
		editable_texture.text = texture_name
	
	%AddTextures.visible = %Container.get_child_count() == 0


func _on_editable_texture_selected(data: Dictionary) -> void:
	selected_texture = data["index"]
	texture_selected.emit(data)


func _on_add_textures_pressed() -> void:
	textures_requested.emit()


func _on_texture_setup_texture_changed(new: Texture2D) -> void:
	var texture: RegionEditorEditableTexture = %Container.get_child(selected_texture)
	texture.icon = new


func _on_texture_setup_texture_renamed(new_name: String) -> void:
	var texture: RegionEditorEditableTexture = %Container.get_child(selected_texture)
	texture.text = new_name
