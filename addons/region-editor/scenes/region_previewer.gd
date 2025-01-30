@tool
class_name RegionEditorRegionPreviewer

extends HBoxContainer

signal selected(is_selected: bool, index: int)
signal deletion_request(index: int)
signal edition_requested(data: Dictionary)

var data: Dictionary = {}
var preview_name: String


func set_data(new: Dictionary, display_name: bool = true, selected: bool = false) -> void:
	# Get the new image if update.
	if not data.get("region_rect", Rect2()).is_equal_approx(new["region_rect"]):
		var image: Image = load(new["base_texture"]).get_image().get_region(new["region_rect"])
		%Preview.texture = ImageTexture.create_from_image(image)
	
	
	data = new
	%Preview.modulate = data["modulate"]
	%PrewiewName.text = data["name"]
	preview_name = %PrewiewName.text
	
	_on_text_visibility_toggled(display_name)
	%Selector.set_pressed_no_signal(selected)


func select(is_selected: bool) -> void:
	%Selector.button_pressed = is_selected


func delete() -> void:
	%Delete.button_pressed = true


func is_selected() -> bool:
	return %Selector.button_pressed


func _on_text_visibility_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		%PrewiewName.text = preview_name
	else:
		%PrewiewName.text = ""


func _on_previewer_pressed() -> void:
	edition_requested.emit(data.duplicate())


func _on_check_box_toggled(toggled_on: bool) -> void:
	selected.emit(toggled_on, get_index())


func _on_delete_pressed() -> void:
	deletion_request.emit(get_index())
