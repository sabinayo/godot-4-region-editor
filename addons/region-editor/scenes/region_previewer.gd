@tool
class_name RegionEditorRegionPreviewer

extends HBoxContainer

enum EditionTypes {
	DISABLED,## No edition request is sent.
	PROPERTIES,## Edition request is sent for properties edition.
	DESCRIPTION,## No edition request is sent. Description will be edited.
}

signal selected(is_selected: bool, index: int)
signal data_updated(data: Dictionary)
signal deletion_request(index: int)
signal edition_requested(data: Dictionary)

var preview_name: String
var edition_type: EditionTypes = EditionTypes.PROPERTIES:
	set(value):
		edition_type = value
		_update_edition_type()

var _data: Dictionary = {}


func change_edition_type(type: EditionTypes) -> void:
	edition_type = type


func _update_edition_type() -> void:
	match edition_type:
		EditionTypes.DISABLED:
			%Previewer.tooltip_text = ""
		
		EditionTypes.PROPERTIES:
			%Previewer.tooltip_text = "Edit Properties."
		
		EditionTypes.DESCRIPTION:
			%Previewer.tooltip_text = "Edit Description."


func set_data(new: Dictionary, display_name: bool = true, selected: bool = false) -> void:
	_update_edition_type()
	update_data(new.merged({
		"display_name": display_name,
		"selected": selected,
	}, true))


func get_data() -> Dictionary:
	_data["id"] = get_index()
	return _data.duplicate()


func update_data(from: Dictionary) -> void:
	# Get the new image if update.
	var stored_rect: Rect2 = _data.get("region_rect", Rect2())
	var new_rect: Rect2 = from.get("region_rect", stored_rect)
	
	if not stored_rect.is_equal_approx(new_rect):
		var texture_path: String = from.get("base_texture", _data.get("base_texture", "res://icon.svg"))
		var image: Image = load(texture_path).get_image().get_region(from["region_rect"])
		%Preview.texture = ImageTexture.create_from_image(image)
	
	# Ensures the presence of essential data
	var update: Dictionary = from.merged({
		"base_texture": from.get("base_texture", _data.get("base_texture", "res://icon.svg")),
		"modulate": from.get("modulate", _data.get("modulate", %Preview.modulate)),
		"name": from.get("name", _data.get("name", %PrewiewName.text)),
		"display_name": from.get("display_name", _data.get("display_name", %PrewiewName.visible)),
		"selected": from.get("selected", _data.get("selected", %Selector.button_pressed)),
	}, true)
	
	_data.merge(from, true)
	%Preview.modulate = _data["modulate"]
	%PrewiewName.text = _data["name"]
	preview_name = %PrewiewName.text
	_update_name_visibility(_data["display_name"])
	%Selector.button_pressed = _data["selected"]
	%Preview.texture_filter = _data["texture_filter"]
	%Preview.texture_repeat = _data["texture_repeat"]
	
	data_updated.emit(get_data())


func select(selected: bool) -> void:
	%Selector.button_pressed = selected
	_data["selected"] = selected


func delete() -> void:
	%Delete.button_pressed = true


func is_selected() -> bool:
	return %Selector.button_pressed


func _on_ids_reassigned() -> void:
	_data["id"] = get_index()
	data_updated.emit(get_data())


func _on_text_visibility_toggled(toggled_on: bool) -> void:
	_update_name_visibility(not toggled_on)


func _update_name_visibility(name_visible: bool) -> void:
	_data["display_name"] = name_visible
	
	if name_visible:
		%PrewiewName.text = preview_name
	else:
		%PrewiewName.text = ""


func _on_previewer_pressed() -> void:
	match edition_type:
		EditionTypes.PROPERTIES:
			edition_requested.emit(get_data())
		
		EditionTypes.DESCRIPTION:
			%DescriptionEdit.title = "Edit Description for: '%s'" % _data["name"]
			%DescriptionEdit.popup_centered()


func _on_check_box_toggled(toggled_on: bool) -> void:
	selected.emit(toggled_on, get_index())


func _on_delete_pressed() -> void:
	deletion_request.emit(get_index())


func _on_export_pressed() -> void:
	var export_options = preload("region_export_dialog.tscn").instantiate()
	add_child(export_options)
	export_options.set_image(%Preview.duplicate())


func export(opts: Dictionary) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = %DragPreview.get_texture().get_image()
	
	var path: String = opts["path"]
	
	if not path.ends_with("/"):
		path += "/"
	
	path += preview_name
	
	var compress_image: Callable = func () -> void:
		if  "compression" in opts:
			image.compress(
				opts["compression"],
				opts["compression_source"],
				opts["astc_format"]
			)
	
	match opts["export_format"]:
		0:
			if not path.ends_with(".png"):
				path += ".png"
			
			image.convert(opts["color_format"])
			compress_image.call()
			image.save_png(path)
		
		1:
			if not path.ends_with(".jpg"):
				path += ".jpg"
			
			image.convert(opts["color_format"])
			compress_image.call()
			image.save_jpg(path, opts["jpg_quality"])
		
		2:
			if not path.ends_with(".webp"):
				path += ".webp"
			
			image.convert(opts["color_format"])
			compress_image.call()
			image.save_webp(path, opts["webp_lossy"], opts["webp_quality"])
		
		3:
			if not path.ends_with(".exr"):
				path += ".exr"
			
			image.convert(opts["color_format"])
			compress_image.call()
			image.save_exr(path, opts["exr_grayscale"])
	
	#set_export_as_success(path)


func _on_description_edit_visibility_changed() -> void:
	_data["description"] = %Description.text
