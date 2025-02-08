@tool
extends HBoxContainer

## Allow global operations on any RegionEditorRegionPreviewersContainer.

const INCOMMING_CONNECTIONS: Dictionary = {
	&"region_selected": &"_on_region_previewer_container_region_selected",
	&"region_deleted": &"_on_region_previewer_container_region_deleted",
	&"region_added": &"_on_region_previewer_container_region_added"
}

const OUTGOING_CONNECTIONS: Dictionary = {
	&"all_regions_selection_requested": &"_on_select_all_regions",
	&"selected_regions_deletion_requested": &"_on_selected_region_deletion_requested",
	&"toggle_regions_names_visibility_requested": &"_on_toggle_regions_names_visibility",
}

signal toggle_regions_names_visibility_requested(toogled_on: bool)
signal all_regions_selection_requested(selected: bool)
signal selected_regions_deletion_requested()
signal multiple_regions_edition_requested()

## Click 'refresh_connections' if set.
@export var regions_container_path: NodePath:
	set(value):
		if regions_container_path:
			break_all_connections()
		
		regions_container_path = value
		add_connections()
#
#@export var refresh_connections: bool = false:
	#set(value):
		#_update_connections(true)


## If true, the 'Multiple Edition' button is displayed when two or more regions are selected.
@export var multiple_edition: bool = true

var _already_connected: bool = false


func add_connections() -> void:
	if not regions_container_path: return
	
	var regions_container = get_node_or_null(regions_container_path)
	
	if not regions_container:
		return
	
	for connection in INCOMMING_CONNECTIONS:
		var connection_established: bool = regions_container.is_connected(
			connection,
			Callable(self, INCOMMING_CONNECTIONS[connection])
		)
		
		if connection_established:
			regions_container.disconnect(
				connection,
				Callable(self, INCOMMING_CONNECTIONS[connection])
			)
		
		regions_container.connect(
			connection,
			Callable(self, INCOMMING_CONNECTIONS[connection])
		, CONNECT_PERSIST)
	
	for connection in OUTGOING_CONNECTIONS:
		var connection_established: bool = is_connected(
			connection,
			Callable(regions_container, OUTGOING_CONNECTIONS[connection])
		)
		
		if connection_established:
			disconnect(
				connection,
				Callable(regions_container, OUTGOING_CONNECTIONS[connection])
			)
		
		connect(
			connection,
			Callable(regions_container, OUTGOING_CONNECTIONS[connection])
		, CONNECT_PERSIST)


func break_all_connections() -> void:
	if not regions_container_path: return
	
	var regions_container = get_node_or_null(regions_container_path)
	
	if not regions_container:
		return
	
	for connection in INCOMMING_CONNECTIONS:
		var connection_established: bool = regions_container.is_connected(
			connection,
			Callable(self, INCOMMING_CONNECTIONS[connection])
		)
		
		if connection_established:
			regions_container.disconnect(
				connection,
				Callable(self, INCOMMING_CONNECTIONS[connection])
			)
	
	for connection in OUTGOING_CONNECTIONS:
		var connection_established: bool = is_connected(
			connection,
			Callable(regions_container, OUTGOING_CONNECTIONS[connection])
		)
		
		if connection_established:
			disconnect(
				connection,
				Callable(regions_container, OUTGOING_CONNECTIONS[connection])
			)



func _update_regions_data() -> void:
	if not regions_container_path: return
	
	var regions_container = get_node(regions_container_path)
	# Regions numb
	%RegionsLabel.text = "Regions: %s" % regions_container.region_count
	
	# Selected regions
	var selected_regions: int = regions_container.selected_regions.size()
	
	%SelectedRegionsLabel.visible = selected_regions > 0
	%SelectedRegionsLabel.text = "%s / %s" % [
		selected_regions,
		regions_container.region_count
	]
	%EditMultipleRegions.visible = multiple_edition and regions_container.selected_regions.size() > 1
	%DeleteSelectedRegions.visible = regions_container.selected_regions.size() >= 1

#region Outgoing connections
func _on_toggle_region_names_toggled(toggled_on: bool) -> void:
	toggle_regions_names_visibility_requested.emit(toggled_on)


func _on_select_all_regions_pressed(selected: bool) -> void:
	if selected:
		%SelectAllRegions.tooltip_text = "Deselect All Regions"
	else:
		%SelectAllRegions.tooltip_text = "Select All Regions"
	
	all_regions_selection_requested.emit(selected)


func _on_edit_multiple_regions_pressed() -> void:
	multiple_regions_edition_requested.emit()


func _on_delete_selected_regions_pressed() -> void:
	selected_regions_deletion_requested.emit()
#endregion

#region Incoming connections
func _on_region_previewer_container_region_added() -> void:
	_update_regions_data()


func _on_region_previewer_container_region_deleted(was_edited: bool, region_id: int) -> void:
	_update_regions_data()


func _on_region_previewer_container_region_selected(is_selected: bool, region_id: int) -> void:
	_update_regions_data()
#endregion
