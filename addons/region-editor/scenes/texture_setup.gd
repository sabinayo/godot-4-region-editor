@tool
extends PanelContainer

signal texture_renamed(new_name: String)
signal texture_changed(new: Texture2D)

## Used to create a resource picker for the texture.
signal resource_picker_requested(sprite: Sprite2D, property: String, requester: NodePath)
## Used to display the Godot Texture Region Editor Node.
signal texture_region_editor_requested(sprite: Sprite2D, requester: NodePath)


enum  ResourcePickerRequests {
	TEXTURE,
	MATERIAL,
}

var _edited_texture: Texture2D = null
# Used to display Godot Texture Region Editor.
var _temp_sprite: Sprite2D = Sprite2D.new()
# Used to display Godot Resource Picker for the texture.
var _resource_picker: EditorResourcePicker


func _ready() -> void:
	_temp_sprite.region_enabled = true


func _on_region_editor_resource_picker_retrieved(resource_picker: EditorResourcePicker, requester: NodePath) -> void:
	if requester == get_path():
		add_resource_picker(resource_picker)


func add_resource_picker(node: EditorResourcePicker) -> void:
	_resource_picker = node
	%TextureEditor.add_child(_resource_picker)
	_resource_picker.edited_resource = _edited_texture
	_resource_picker.resource_changed.connect(_on_resource_picker_resource_changed)


func _on_resource_picker_resource_changed(resource: Resource) -> void:
	if resource is Texture2D:
		texture_changed.emit(resource)
		_edited_texture = resource
		_temp_sprite.texture = resource
	else:
		_resource_picker.edited_resource = _temp_sprite.texture


func _on_add_region() -> void:
	if not _edited_texture:
		return
	
	_temp_sprite.texture = _edited_texture
	texture_region_editor_requested.emit(_temp_sprite, get_path())


func _on_texture_selected(data: Dictionary) -> void:
	_edited_texture = data["texture"]
	_temp_sprite.texture = _edited_texture
	%TextureName.text = data["texture_name"]
	
	if %TextureEditor.get_child_count() == 1:
		resource_picker_requested.emit(_temp_sprite, "texture", get_path())


func _on_texture_name_text_changed(new_text: String) -> void:
	texture_renamed.emit(new_text)
