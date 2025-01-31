@tool
class_name RegionEditorRegionPreviewersContainer

extends PanelContainer

signal region_export_requested(texture: TextureRect)
signal region_selected(is_selected: bool, region_id: int)
signal region_updated(data: Dictionary)
signal region_added()
signal region_deleted(was_edited: bool, region_id: int)
signal region_edition_requested(data: Dictionary)
signal region_names_visibility_changed(visibles: bool)

const MINIMUM_PREVIEW_SIZE: int = 160
const REGION_PREVIEWER: PackedScene = preload("region_previewer.tscn")

var region_count: int = 0
var selected_regions: PackedInt32Array = []
var edited_region: int = -1

var _temp_sprite: Sprite2D = Sprite2D.new()
var _update_previewers_display: bool = false
var _display_regions_names: bool = false
var _select_all_regions: bool = false


func delete_regions() -> void:
	for region: RegionEditorRegionPreviewer in %Container.get_children():
		region._on_delete_pressed()


func add_regions(datas: Array[Dictionary]) -> void:
	for data: Dictionary in datas:
		var preview: RegionEditorRegionPreviewer = REGION_PREVIEWER.instantiate()
		%Container.add_child(preview)
		region_count += 1
		preview.selected.connect(_on_region_selected)
		preview.data_updated.connect(_on_region_data_updated)
		preview.edition_requested.connect(_on_region_edition_requested)
		preview.export_requested.connect(_on_region_export_reequested)
		preview.deletion_request.connect(_on_region_deletion_requested)
		region_names_visibility_changed.connect(Callable(preview, &"_on_text_visibility_toggled"))
		preview.set_data(data)
		region_added.emit()


func add_region_from(sprite: Sprite2D) -> void:
	_temp_sprite.texture = sprite.texture
	_temp_sprite.region_rect = sprite.region_rect
	
	var preview: RegionEditorRegionPreviewer = REGION_PREVIEWER.instantiate()
	%Container.add_child(preview)
	region_count += 1
	preview.selected.connect(_on_region_selected)
	preview.data_updated.connect(_on_region_data_updated)
	preview.edition_requested.connect(_on_region_edition_requested)
	preview.export_requested.connect(_on_region_export_reequested)
	preview.deletion_request.connect(_on_region_deletion_requested)
	region_names_visibility_changed.connect(Callable(preview, &"_on_text_visibility_toggled"))
	
	var preview_id: int = preview.get_index()
	
	var data: Dictionary = {
		"name": "RegionRect_%s" % (preview_id + 1),
		"id": preview_id,
		"region_rect": sprite.region_rect,
		"base_texture": sprite.texture.resource_path,
		"modulate": sprite.modulate,
		"texture_filter": sprite.texture_filter,
		"texture_repeat": sprite.texture_repeat,
	}
	
	preview.set_data(data, _display_regions_names, _select_all_regions)
	region_added.emit()


func get_selected_regions_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	
	for region_id: int in selected_regions:
		data.append(%Container.get_child(region_id).get_data())
	
	return data


func _on_region_export_reequested(texture: TextureRect) -> void:
	region_export_requested.emit(texture)


func _on_selected_region_deletion_requested() -> void:
	# Use NodePath instead of ids as ids will changes onde
	# any region is deleted
	var regions_to_delete: Array[NodePath] = []
	
	for region_id: int in selected_regions:
		var region: RegionEditorRegionPreviewer = %Container.get_child(region_id) as RegionEditorRegionPreviewer
		regions_to_delete.append(region.get_path())
	
	for region_path: NodePath in regions_to_delete:
		var region: RegionEditorRegionPreviewer = get_node_or_null(region_path)
		
		if region:
			region._on_delete_pressed()


func _on_region_deletion_requested(region_id: int) -> void:
	var preview: RegionEditorRegionPreviewer = %Container.get_child(region_id)
	
	if preview.is_selected():
		_remove_selected_region(region_id)

	preview.queue_free()
	
	region_count -= 1
	region_deleted.emit(region_id == edited_region, region_id)
	edited_region = -1


func _set_region_as_selected(region_id: int) -> void:
	if not (region_id in selected_regions):
		selected_regions.append(region_id)


func _remove_selected_region(region_id: int) -> void:
	var idx: int = selected_regions.find(region_id)
	
	if idx != -1:
		selected_regions.remove_at(idx)


func _on_region_selected(is_selected: bool, region_id: int) -> void:
	if is_selected:
		_set_region_as_selected(region_id)
	else:
		_remove_selected_region(region_id)
	
	region_selected.emit(is_selected, region_id)


func _on_region_edition_requested(data: Dictionary) -> void:
	edited_region = data["id"]
	region_edition_requested.emit(data)


func _on_region_data_updated(data: Dictionary) -> void:
	region_updated.emit(data)


func _on_region_properties_property_updated(data: Dictionary) -> void:
	var preview: RegionEditorRegionPreviewer = %Container.get_child(data["id"])
	preview.set_data(data, _display_regions_names, _select_all_regions)


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
	_display_regions_names = toggled_on
	region_names_visibility_changed.emit(toggled_on)


func _on_select_all_regions(are_selected: bool) -> void:
	_select_all_regions = are_selected
	
	for region: RegionEditorRegionPreviewer in %Container.get_children():
		region.select(are_selected)


func set_data_from_texture_setup(data: Dictionary) -> void:
	for region: RegionEditorRegionPreviewer in %Container.get_children():
		region.update_data(data)


func _on_resized() -> void:
	update_previewers_display()
