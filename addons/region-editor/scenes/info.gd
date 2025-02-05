@tool
extends HBoxContainer

class_name RegionEditorInfo

enum Types {
	SUCCESS,
	WARNING,
	ERROR,
}

signal info_time_ended()

const ICONS: Dictionary = {
	Types.SUCCESS: preload("../icons/StatusSuccess.svg"),
	Types.WARNING: preload("../icons/StatusWarning.svg"),
	Types.ERROR: preload("../icons/StatusError.svg"),
}

var _default_info: Dictionary = {
	"type": 1,
	"text": "",
}


func set_default_info(type: Types, text: String) -> void:
	_default_info["type"] = type
	_default_info["text"] = text
	

func _update_state(type: Types, text: String) -> void:
	%Label.text = text
	%Icon.texture  = ICONS[type]


func display(type: Types, text: String, time: float = 0.0) -> void:
	show()
	_update_state(type, text)
	
	if time > 0.0:
		if not %Timer.is_stopped():
			%Timer.stop()
		
		%Timer.start(time)


func _on_timer_timeout() -> void:
	info_time_ended.emit()
	
	visible = _default_info["text"] != ""
	_update_state(_default_info["type"], _default_info["text"])
