@tool
class_name RegionEditorRegionPreviewer

extends Button

signal selected()

var data: Dictionary = {}
var preview_name: String


func set_data(new: Dictionary) -> void:
	# Get the new image if update.
	if not data.get("region_rect", Rect2()).is_equal_approx(new["region_rect"]):
		var image: Image = load(new["base_texture"]).get_image().get_region(new["region_rect"])
		icon = ImageTexture.create_from_image(image)
	
	data = new
	text = data["name"]
	preview_name = text



func _pressed() -> void:
	selected.emit(data.duplicate())


func _on_text_visibility_toggled(toggled_on: bool) -> void:
	if toggled_on:
		text = preview_name
	else:
		text = ""
