@tool
class_name RegionEditorRegionPreviewer

extends HBoxContainer

signal selected(is_selected: bool)
signal edition_requested(data: Dictionary)

var data: Dictionary = {}
var preview_name: String


func set_data(new: Dictionary, display_name: bool = true) -> void:
	# Get the new image if update.
	if not data.get("region_rect", Rect2()).is_equal_approx(new["region_rect"]):
		var image: Image = load(new["base_texture"]).get_image().get_region(new["region_rect"])
		%Previewer.icon = ImageTexture.create_from_image(image)
	
	data = new
	%Previewer.text = data["name"]
	preview_name = %Previewer.text
	
	_on_text_visibility_toggled(display_name)


func _on_text_visibility_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		%Previewer.text = preview_name
	else:
		%Previewer.text = ""


func _on_previewer_pressed() -> void:
	edition_requested.emit(data.duplicate())


func _on_check_box_toggled(toggled_on: bool) -> void:
	selected.emit(toggled_on)


func select(is_selected: bool) -> void:
	%Selector.button_pressed = is_selected
