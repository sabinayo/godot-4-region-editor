@tool
extends PanelContainer

const REGION_PREVIEWER: PackedScene = preload("region_previewer.tscn")


func set_data(datas: Array[Dictionary]) -> void:
	%RegionPreviewerContainer.add_regions(datas)


func cancel_export() -> void:
	%RegionPreviewerContainer.delete_regions()


func export(path: String) -> void:
	pass


func _on_region_selected() -> void:
	pass

func _on_region_edition_requested() -> void:
	pass


func _on_region_deletion_requested() -> void:
	pass
