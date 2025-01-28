@tool
extends PanelContainer

signal region_selected(data: Dictionary)
signal region_names_visibility_changed(visibles: bool)

const MINIMUM_PREVIEW_SIZE: int = 50
const previewer: PackedScene = preload("region_previewer.tscn")

var _temp_sprite: Sprite2D = Sprite2D.new()
var _update_previewers_display: bool = false


func add_region_from(sprite: Sprite2D) -> void:
	_temp_sprite.texture = sprite.texture
	_temp_sprite.region_rect = sprite.region_rect
	
	var preview: Button = previewer.instantiate()
	%Container.add_child(preview)
	preview.selected.connect(_on_region_selected)
	region_names_visibility_changed.connect(Callable(preview, &"_on_text_visibility_toggled"))
	
	var preview_id: int = preview.get_index()
	
	var data: Dictionary = {
		"name": "RegionRect_%s" % (preview_id + 1),
		"id": preview_id,
		"region_rect": sprite.region_rect,
		"base_texture": sprite.texture.resource_path,
	}
	
	var image: Image = sprite.texture.get_image().get_region(sprite.region_rect)
	preview.icon = ImageTexture.create_from_image(image)
	preview.set_data(data)


func _on_region_selected(data: Dictionary) -> void:
	region_selected.emit(data)


func _on_region_properties_property_updated(data: Dictionary) -> void:
	var preview: RegionEditorRegionPreviewer = %Container.get_child(data["id"])
	preview.set_data(data)


func _ready() -> void:
	_temp_sprite.region_enabled = true
	update_previewers_display()


# Detect the HSplit Drag End by retrieving the last InputEventMouseButton or InputEventScreenTouch
func _input(event: InputEvent) -> void:
	if (
		not _update_previewers_display
		or not (event.get_class() in ["InputEventMouseButton", "InputEventScreenTouch"])
	):
		return
	
	update_previewers_display()
	_update_previewers_display = false


func update_previewers_display() -> void:
	var container_size: Vector2 = size
	var columns: int = container_size.x / MINIMUM_PREVIEW_SIZE
	
	if columns >= 1:
		%Container.columns = columns
	
	%Container.show()


func _on_hsplitcont_dragged(offset: int) -> void:
	_update_previewers_display = true
	%Container.hide()


func _on_region_properties_dock_visibility_changed() -> void:
	# Let Dock use enougth space
	%Container.columns = 4
	# Wait for auto resize by the Engine.
	await get_tree().process_frame # Size not always updated here.
	await get_tree().process_frame # Size Updated.
	update_previewers_display()


func _on_toggle_regions_names_visibility(toggled_on: bool) -> void:
	region_names_visibility_changed.emit(toggled_on)
