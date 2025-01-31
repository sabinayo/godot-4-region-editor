@tool
extends PanelContainer

signal empty_container()
signal textures_requested()
signal texture_selected(data: Dictionary)
signal texture_deleted()
signal texture_added()
signal search_applied(filter: String)

var _editable_texture: PackedScene = preload("editable_texture.tscn")

var selected_texture: int = -1
var textures_count: int = 0
var recognized_extensions: PackedStringArray = ResourceLoader.get_recognized_extensions_for_type("Image")


func delete_selected_texture() -> void:
	if selected_texture != -1:
		textures_count -= 1
		%Container.get_child(selected_texture).queue_free()
		texture_deleted.emit()
		
		if textures_count == 0:
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
		textures_count += 1
		
		search_applied.connect(Callable(editable_texture, &"_on_search_applied"))
		editable_texture.selected.connect(_on_editable_texture_selected)
		
		var data: Dictionary = {
			"texture_path": file_path,
			"texture_name": texture_name,
		}
		
		editable_texture.set_data(data)
		texture_added.emit()
	
	%AddTextures.visible = textures_count == 0


func _on_editable_texture_selected(data: Dictionary) -> void:
	selected_texture = data["index"]
	texture_selected.emit(data)


func _on_add_textures_pressed() -> void:
	textures_requested.emit()


func _on_texture_setup_texture_changed(new: Texture2D) -> void:
	var texture: RegionEditorEditableTexture = %Container.get_child(selected_texture)
	texture.update_data({
		"texture_path": new.resource_path
	})


func _on_texture_setup_texture_renamed(new_name: String) -> void:
	var texture: RegionEditorEditableTexture = %Container.get_child(selected_texture)
	texture.update_data({
		"texture_name": new_name
	})


func _on_search_text_changed(new_text: String) -> void:
	search_applied.emit(new_text)
