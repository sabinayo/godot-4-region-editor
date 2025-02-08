@tool
class_name RegionEditorEditableTexture

extends Button

signal selected(id: int)

var _data: Dictionary = {}


func set_data(data: Dictionary) -> void:
	update_data(data)


func update_data(from: Dictionary) -> void:
	var stored_path: String = _data.get("texture_path", "")
	var new_path: String = from.get("texture_path", stored_path)
	
	if stored_path != new_path:
		var texture_path: String = from.get("texture_path", _data.get("texture_path", "res://icon.svg"))
		icon = load(texture_path)
	
	var update: Dictionary = from.merged({
		"texture_path": from.get("texture_path", _data.get("texture_path", "res://icon.svg")),
		"texture_name": from.get("texture_name", _data.get("texture_name", text)),
	}, true)
	
	_data.merge(from, true)
	text = _data["texture_name"]



func _pressed() -> void:
	var data: Dictionary = {
		"index": get_index(),
		"texture_name": text,
		"texture_path": icon.resource_path,
	}
	selected.emit(data)


func _on_search_applied(new_text: String) -> void:
	var will_be_visible: bool = new_text == ""
	
	if not will_be_visible:
		for c in new_text:
			if c in _data["texture_name"]:
				will_be_visible = true
				break
	
	visible = will_be_visible
