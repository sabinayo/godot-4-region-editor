@tool
extends PanelContainer

signal texture_region_editor_requested(sprite: Sprite2D, requester: NodePath)
## Only Region id and updated properties are sent.
signal property_updated(data: Dictionary)

const REGION_EXPORT_DIALOG: PackedScene = preload("region_export_dialog.tscn")
const REGIONS_EXPORT_DIALOG: PackedScene = preload("regions_export_dialog.tscn")

@export var _hidden_on_multiple_edition: Array[NodePath]

var _data: Dictionary = {}
var _edited_regions_data: Array[Dictionary] = []
var _edited_regions_id: PackedInt32Array = []
var _multiple_edition: bool = false:
	set(value):
		_multiple_edition = value
		
		for node_path in _hidden_on_multiple_edition:
			get_node(node_path).visible = not _multiple_edition

var _temp_sprite: Sprite2D = Sprite2D.new()
var _updating: bool = false


func set_data(new: Dictionary) -> void:
	_updating = true
	
	# Ensures the presence of essential data
	var update: Dictionary = new.merged({
		"base_texture": new.get("base_texture", _data.get("base_texture", "res://icon.svg")),
		"modulate": new.get("modulate", _data.get("modulate", %Modulate.color)),
		"name": new.get("name", _data.get("name", %Name.text)),
		"region_rect": new.get("region_rect", _data.get("region_rect", Rect2())),
	}, true)
	
	_data.merge(new, true)
	
	
	_data = new
	%Name.text = _data["name"]
	_temp_sprite.region_enabled = true
	_temp_sprite.region_rect = _data["region_rect"]
	%Modulate.color = _data["modulate"]
	%CopyRectData.tooltip_text = var_to_str(_data["region_rect"])
	%CopyResourcePath.tooltip_text = _data["base_texture"]
	_update_preview()
	_updating = false


func edit_multiple_regions(edit: bool, datas: Array[Dictionary], color: Color) -> void:
	_multiple_edition = edit
	_edited_regions_data = datas
	_edited_regions_id.clear()
	
	for data in datas:
		_edited_regions_id.append(data["id"])
	
	_updating = true
	%Modulate.color = color
	_updating = false


func _on_copy_rect_data_pressed() -> void:
	DisplayServer.clipboard_set(var_to_str(_data["region_rect"]))


func _on_copy_resource_path_pressed() -> void:
	DisplayServer.clipboard_set(_data["base_texture"])


func _on_copy_image_pressed() -> void:
	DisplayServer.clipboard_set(var_to_str(%Preview.texture.get_image()))


func _on_name_text_changed(new_text: String) -> void:
	if new_text.is_valid_filename():
		_data["name"] = new_text
		_set_properties_as_updated(["name"])


func _on_name_text_submitted(new_text: String) -> void:
	return
	
	if not new_text.is_valid_filename():
		%Name.text = _data["name"]
	else:
		_set_properties_as_updated(["name"])


func _on_update_rect_pressed() -> void:
	_temp_sprite.texture = load(_data["base_texture"])
	# Duplicate the sprite to avoid data collisions
	texture_region_editor_requested.emit(_temp_sprite.duplicate(), get_path())


func _on_region_editor_texture_region_edited(sprite: Sprite2D, requester: NodePath) -> void:
	if requester == get_path():
		print("hum????")
		_data["region_rect"] = sprite.region_rect
		%CopyRectData.tooltip_text = var_to_str(_data["region_rect"])
		_set_properties_as_updated(["region_rect"])
		_update_preview()


func _on_modulate_color_changed(color: Color) -> void:
	if _updating: return
	
	_data["modulate"] = color
	%Preview.modulate = color
	_set_properties_as_updated(["modulate"])


func _on_export_pressed() -> void:
	if _multiple_edition:
		var export_dialog = REGIONS_EXPORT_DIALOG.instantiate()
		add_child(export_dialog)
		export_dialog.set_data(_edited_regions_data)
	else:
		var export_dialog = REGION_EXPORT_DIALOG.instantiate()
		add_child(export_dialog)
		export_dialog.set_image(%Preview.duplicate())


func _update_preview() -> void:
	var image: Image = load(_data["base_texture"]).get_image()
	%Preview.texture = ImageTexture.create_from_image(image.get_region(_data["region_rect"]))
	%Preview.modulate = _data["modulate"]
	
	var texture_size: Vector2 = image.get_size()
	%PreviewInfos.text = """
	%s x %s %s
	%s
	Memory: %s
	""" % [
		texture_size.x, texture_size.y,
		get_image_format_literal(image.get_format()),
		"No Mipmaps" if not image.has_mipmaps() else "Has Mipmaps",
		get_image_real_size(image.get_data_size())
	]
	%RegionCollisionEditor.set_texture_preview(%Preview.duplicate())


func _set_properties_as_updated(properties: PackedStringArray) -> void:
	var update: Dictionary = {}
	
	for property in properties:
		if property in _data:
			update[property] = _data[property]
	
	if _multiple_edition:
		update["ids"] = _edited_regions_id
	else:
		update["id"] = _data["id"]
	
	print("%s updated - ids: %s" % [properties, _edited_regions_id])
	property_updated.emit(update.duplicate())


func get_image_real_size(image_size: int) -> String:
	var kilo_bytes: float = round(image_size / 1024.0)
	var mega_bytes: float = round(image_size / 1048576.0)
	
	if mega_bytes >= 1.0:
		return " %sMo" % mega_bytes
	
	else:
		return " %sKo" % kilo_bytes
	
	return ""


func get_image_format_literal(format: Image.Format) -> String:
	match format:
		Image.FORMAT_L8: return "L8"
		Image.FORMAT_LA8: return "LA8"
		Image.FORMAT_R8: return "R8"
		Image.FORMAT_RG8: return "RG8"
		Image.FORMAT_RGB8: return "RGB8"
		Image.FORMAT_RGBA8: return "RGBA8"
		Image.FORMAT_RGBA4444: return "RGBA4444"
		Image.FORMAT_RF: return "RF"
		Image.FORMAT_RGF: return "RGF"
		Image.FORMAT_RGBF: return "RGBF"
		Image.FORMAT_RGBAF: return "RGBAF"
		Image.FORMAT_RH: return "RH"
		Image.FORMAT_RGH: return "RGH"
		Image.FORMAT_RGBH: return "RGBH"
		Image.FORMAT_RGBAH: return "RGBAH"
		Image.FORMAT_RGBE9995: return "RGBE9995"
		Image.FORMAT_DXT1: return "DXT1"
		Image.FORMAT_DXT3: return "DXT3"
		Image.FORMAT_DXT5: return "DXT5"
		Image.FORMAT_RGTC_R: return "RGTC_R"
		Image.FORMAT_RGTC_RG: return "RGTC_RG"
		Image.FORMAT_BPTC_RGBA: return "BPTC_RGBA"
		Image.FORMAT_BPTC_RGBF: return "BPTC_RGBF"
		Image.FORMAT_BPTC_RGBFU: return "BPTC_RGBFU"
		Image.FORMAT_ETC: return "ETC"
		Image.FORMAT_ETC2_R11: return "ETC2_R11"
		Image.FORMAT_ETC2_R11S: return "ETC2_R11S"
		Image.FORMAT_ETC2_RG11: return "ETC2_RG11"
		Image.FORMAT_ETC2_RG11S: return "ETC2_RG11S"
		Image.FORMAT_ETC2_RGB8: return "ETC2_RGB8"
		Image.FORMAT_ETC2_RGBA8: return "ETC2_RGBA8"
		Image.FORMAT_ETC2_RGB8A1: return "ETC2_RGB8A1"
		_:
			return "Unknown Format"


func _on_region_previewer_container_region_deleted(was_edited: bool, region_id: int) -> void:
	if _multiple_edition:
		if region_id in _edited_regions_id:
			_edited_regions_id.remove_at(_edited_regions_id.find(region_id))
			
			var removed_idx: int = 0
			
			for data in _edited_regions_data:
				if data["id"] == region_id:
					break
				
				removed_idx += 1
			
			_edited_regions_data.remove_at(removed_idx)
			
			var new_ids: PackedInt32Array = _edited_regions_id.duplicate()
			
			for id in _edited_regions_id:
				if id >= removed_idx:
					var idx: int = new_ids.find(id)
					new_ids[idx] = id - 1
			
			_edited_regions_id = new_ids.duplicate()
			
			var dic_idx_to_remove: int = -1
			
			for data in _edited_regions_data:
				if not (data["id"] in _edited_regions_id):
					dic_idx_to_remove = _edited_regions_data.find(data)
				else:
					var idx: int = _edited_regions_id.find(data["id"])
					data["id"] = new_ids[idx]
			
			_edited_regions_data.remove_at(dic_idx_to_remove)
			_edited_regions_id = new_ids


func _on_region_collision_editor_distraction_free_changed(enabled: bool) -> void:
	%Distractions.visible = not enabled
