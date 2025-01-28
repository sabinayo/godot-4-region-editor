@tool
class_name RegionEditorEditableTexture

extends Button

signal selected(id: int)


func _pressed() -> void:
	var data: Dictionary = {
		"index": get_index(),
		"texture": icon,
		"texture_name": text,
		"texture_path": icon.resource_path,
	}
	selected.emit(data)
