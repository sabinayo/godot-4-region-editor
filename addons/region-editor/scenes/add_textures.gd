@tool
extends Button


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data.get("type", "") == "files"


func _drop_data(at_position: Vector2, data: Variant) -> void:
	get_parent().add_textures(data["files"])
