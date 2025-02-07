@tool
class_name RegionEditorRegionPreviewersContainer

extends PanelContainer

signal region_selected(is_selected: bool, region_id: int)
signal region_updated(data: Dictionary)
signal region_added()
signal regions_ids_reasigned()
signal region_deleted(was_edited: bool, region_id: int)
signal region_edition_requested(data: Dictionary)
signal region_names_visibility_changed(visibles: bool)
signal edition_type_changed(new: RegionEditorRegionPreviewer.EditionTypes)

const MINIMUM_PREVIEW_SIZE: int = 160
const REGION_PREVIEWER: PackedScene = preload("region_previewer.tscn")

@export var edition_type: RegionEditorRegionPreviewer.EditionTypes = RegionEditorRegionPreviewer.EditionTypes.PROPERTIES

var region_count: int = 0:
	get():
		return %Container.get_child_count()

var selected_regions: PackedInt32Array = []
var edited_region: int = -1

var _temp_sprite: Sprite2D = Sprite2D.new()
var _update_previewers_display: bool = false
var _display_regions_names: bool = false
var _select_all_regions: bool = false


func delete_regions() -> void:
	for region: RegionEditorRegionPreviewer in %Container.get_children():
		region._on_delete_pressed()


func change_region_edition_type(to: RegionEditorRegionPreviewer.EditionTypes) -> void:
	edition_type_changed.emit(to)


func add_regions(datas: Array[Dictionary]) -> void:
	for data: Dictionary in datas:
		var preview: RegionEditorRegionPreviewer = REGION_PREVIEWER.instantiate()
		%Container.add_child(preview)
		region_count += 1
		_make_region_preview_usable(preview, data)
		region_added.emit()


func _make_region_preview_usable(preview: RegionEditorRegionPreviewer, data: Dictionary) -> void:
	edition_type_changed.connect(preview.change_edition_type)
	regions_ids_reasigned.connect(preview._on_ids_reassigned)
	
	preview.edition_type = edition_type
	preview.selected.connect(_on_region_selected)
	preview.data_updated.connect(_on_region_data_updated)
	preview.edition_requested.connect(_on_region_edition_requested)
	preview.deletion_request.connect(_on_region_deletion_requested)
	region_names_visibility_changed.connect(Callable(preview, &"_on_text_visibility_toggled"))
	preview.set_data(data)


func add_region_from(sprite: Sprite2D) -> void:
	_temp_sprite.texture = sprite.texture
	_temp_sprite.region_rect = sprite.region_rect
	
	var preview: RegionEditorRegionPreviewer = REGION_PREVIEWER.instantiate()
	%Container.add_child(preview)
	region_count += 1
	
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
	
	_make_region_preview_usable(preview, data)
	region_added.emit()


func update_region_data(data: Dictionary) -> void:
	%Container.get_child(data.get("id", -1)).update_data(data)


func get_selected_regions_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	
	for region_id: int in selected_regions:
		data.append(%Container.get_child(region_id).get_data())
	
	return data


func get_regions_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	
	for region: RegionEditorRegionPreviewer in %Container.get_children():
		data.append(region.get_data())
	
	return data


func _on_selected_region_deletion_requested() -> void:
	# Use NodePath instead of ids as ids will changes once
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
	preview.queue_free()
	
	await preview.tree_exited
	regions_ids_reasigned.emit()
	await get_tree().process_frame
	_update_selected_regions_count()
	region_count = %Container.get_child_count()
	region_deleted.emit(region_id == edited_region, region_id)
	
	if region_id == edited_region:
		edited_region = -100


func _on_region_selected(is_selected: bool, region_id: int) -> void:
	_update_selected_regions_count()
	region_selected.emit(is_selected, region_id)


func _update_selected_regions_count() -> void:
	selected_regions.clear()
	
	for child: RegionEditorRegionPreviewer in %Container.get_children():
		if child.is_selected():
			selected_regions.append(child.get_index())


func _on_region_edition_requested(data: Dictionary) -> void:
	edited_region = data["id"]
	region_edition_requested.emit(data)


func _on_region_data_updated(data: Dictionary) -> void:
	region_updated.emit(data)


func _on_region_properties_property_updated(data: Dictionary) -> void:
	if "id" in data:
		var preview: RegionEditorRegionPreviewer = %Container.get_child(data["id"])
		preview.set_data(data, _display_regions_names, _select_all_regions)
	
	elif "ids" in data:
		for id: int in data["ids"]:
			var preview: RegionEditorRegionPreviewer = %Container.get_child(id)
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
