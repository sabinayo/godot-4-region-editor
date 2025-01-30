@tool
extends PanelContainer

signal texture_renamed(new_name: String)
signal texture_changed(new: Texture2D)
signal texture_data_updated(data: Dictionary)

## Used to create a resource picker for the texture.
signal resource_picker_requested(sprite: Sprite2D, property: String, requester: NodePath)
## Used to display the Godot Texture Region Editor Node.
signal texture_region_editor_requested(sprite: Sprite2D, requester: NodePath)


enum ResourcePickerRequests {
	NONE,
	TEXTURE,
	MATERIAL,
}

# Used to make differe,ce between nodes requesting resource picker.
var _resource_picker_request
var _edited_texture: Texture2D = null
var _edited_material: Material = null
# Used to display Godot Texture Region Editor.
var _temp_sprite: Sprite2D = Sprite2D.new()
# Used to display Godot Resource Picker for the texture.
var _texture_resource_picker: EditorResourcePicker
var _material_resource_picker: EditorResourcePicker

var _texture_data: Dictionary = {
	"modulate": Color.WHITE,
	"self_modulate": Color.WHITE,
	"filter": TextureFilter.TEXTURE_FILTER_NEAREST,
	"repeat": TextureRepeat.TEXTURE_REPEAT_DISABLED,
}
var _updating: bool = false


func _ready() -> void:
	_temp_sprite.region_enabled = true


func _on_region_editor_resource_picker_retrieved(resource_picker: EditorResourcePicker, requester: NodePath) -> void:
	if requester == get_path():
		add_resource_picker(resource_picker)


func add_resource_picker(node: EditorResourcePicker) -> void:
	match _resource_picker_request:
		ResourcePickerRequests.TEXTURE:
			_texture_resource_picker = node
			%TextureEditor.add_child(_texture_resource_picker)
			_texture_resource_picker.edited_resource = _edited_texture
			_texture_resource_picker.resource_changed.connect(_on_texture_resource_picker_resource_changed)
			
			if %MaterialEditor.get_child_count() == 1:
				_resource_picker_request = ResourcePickerRequests.MATERIAL
				resource_picker_requested.emit(_temp_sprite, "material", get_path())
		
		ResourcePickerRequests.MATERIAL:
			_resource_picker_request = ResourcePickerRequests.NONE
			_material_resource_picker = node
			%MaterialEditor.add_child(_material_resource_picker)
			_material_resource_picker.edited_resource =_edited_material
			_material_resource_picker.resource_changed.connect(_on_material_resource_picker_resource_changed)


func _on_texture_resource_picker_resource_changed(resource: Resource) -> void:
	if resource is Material:
		_edited_material = resource
	else:
		_material_resource_picker.edited_resource = _edited_material


func _on_material_resource_picker_resource_changed(resource: Resource) -> void:
	if resource is Texture2D:
		texture_changed.emit(resource)
		_edited_texture = resource
		_temp_sprite.texture = resource
	else:
		_texture_resource_picker.edited_resource = _temp_sprite.texture


func _on_add_region() -> void:
	if not _edited_texture:
		return
	
	_temp_sprite.texture = _edited_texture
	_temp_sprite.modulate = %SelfModulate.color
	
	if %SelfModulate.color == Color.WHITE:
		_temp_sprite.modulate = %Modulate.color
	
	_temp_sprite.texture_filter = %TextureFilter.selected
	_temp_sprite.texture_repeat = %TextureRepeat.selected
	texture_region_editor_requested.emit(_temp_sprite, get_path())


func _on_texture_selected(data: Dictionary) -> void:
	_edited_texture = data["texture"]
	_temp_sprite.texture = _edited_texture
	%TextureName.text = data["texture_name"]
	
	if %TextureEditor.get_child_count() == 1:
		_resource_picker_request = ResourcePickerRequests.TEXTURE
		resource_picker_requested.emit(_temp_sprite, "texture", get_path())


func _on_texture_filter_selected(index: int) -> void:
	var filter: int = index + 1
	_texture_data["filter"] = filter
	_temp_sprite.texture_filter = filter
	texture_data_updated.emit(_texture_data)


func _on_texture_repeat_selected(index: int) -> void:
	var repeat: int = index + 1
	_texture_data["repeat"] = repeat
	_temp_sprite.texture_repeat = repeat
	texture_data_updated.emit(_texture_data)


func _on_texture_name_text_changed(new_text: String) -> void:
	texture_renamed.emit(new_text)


func _on_change_texture_modulate(color: Color) -> void:
	_updating = true
	%Modulate.color = color


func _on_modulate_color_changed(color: Color) -> void:
	_texture_data["modulate"] = color
	_temp_sprite.modulate = color
	
	if not _updating:
		texture_data_updated.emit(_texture_data)
	
	_updating = false


func _on_change_texture_self_modulate(color: Color) -> void:
	_updating = true
	%SelfModulate.color = color


func _on_self_modulate_color_changed(color: Color) -> void:
	_texture_data["self_modulate"] = color
	_temp_sprite.modulate = color
	
	if not _updating:
		texture_data_updated.emit(_texture_data)
	
	_updating = false
