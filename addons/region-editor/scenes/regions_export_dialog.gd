@tool
class_name RegionEditorRegionsExportDialog

extends ConfirmationDialog

## Export Dialog used to export a multiple regions.
## Queuefree once operation is canceled, succesful or not.[br]
## Add an instance to any node and activate it with the method 'set_data(regions_data: Array[Dictionary])').

signal export_canceled()
signal export_successful(path: String)


const REGION_PREVIEWER: PackedScene = preload("region_previewer.tscn")


func set_data(regions_data: Array[Dictionary]) -> void:
	%RegionPreviewerContainer.add_regions(regions_data)
	popup_centered()


func export(path: String) -> void:
	export_successful.emit(path)
	queue_free()


func _on_confirmed() -> void:
	pass # Replace with function body.


func _on_canceled() -> void:
	export_canceled.emit()
	queue_free()


func _on_region_previewer_container_region_deleted(was_edited: bool, region_id: int) -> void:
	if %RegionPreviewerContainer.region_count == 0:
		get_ok_button().disabled = true
