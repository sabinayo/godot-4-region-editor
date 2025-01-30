@tool
class_name RegionEditorRegionPreviewer

extends HBoxContainer

signal selected(is_selected: bool, index: int)
signal data_updated(data: Dictionary)
signal deletion_request(index: int)
signal edition_requested(data: Dictionary)

var _data: Dictionary = {}
var preview_name: String


func set_data(new: Dictionary, display_name: bool = true, selected: bool = false) -> void:
	update_data(new.merged({
		"display_name": display_name,
		"selected": selected,
	}, true))


func update_data(from: Dictionary) -> void:
	# Get the new image if update.
	var stored_rect: Rect2 = _data.get("region_rect", Rect2())
	var new_rect: Rect2 = from.get("region_rect", stored_rect)
	
	if not stored_rect.is_equal_approx(new_rect):
		var texture_path: String = from.get("base_texture", _data.get("base_texture", "res://icon.svg"))
		var image: Image = load(texture_path).get_image().get_region(from["region_rect"])
		%Preview.texture = ImageTexture.create_from_image(image)
	
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
	
	data_updated.emit(_data.duplicate())


func select(is_selected: bool) -> void:
	%Selector.button_pressed = is_selected


func delete() -> void:
	%Delete.button_pressed = true


func is_selected() -> bool:
	return %Selector.button_pressed


func _on_text_visibility_toggled(toggled_on: bool) -> void:
	_update_name_visibility(not toggled_on)


func _update_name_visibility(name_visible: bool) -> void:
	_data["display_name"] = name_visible
	
	if name_visible:
		%PrewiewName.text = preview_name
	else:
		%PrewiewName.text = ""


func _on_previewer_pressed() -> void:
	edition_requested.emit(_data.duplicate())


func _on_check_box_toggled(toggled_on: bool) -> void:
	selected.emit(toggled_on, get_index())


func _on_delete_pressed() -> void:
	deletion_request.emit(get_index())
