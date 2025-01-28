@tool
class_name RegionEditorRegionReviewer

extends Button

signal selected()

var data: Dictionary = {}


func set_data(new: Dictionary) -> void:
	data = new


func _pressed() -> void:
	selected.emit(data)
