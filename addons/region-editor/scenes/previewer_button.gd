@tool
extends Button

@export var drag_export_viewport_path: NodePath


var has_file: bool = false


func _get_drag_data(at_position: Vector2) -> Variant:
	var filesystem: EditorFileSystem = EditorInterface.get_resource_filesystem()
	var image_path: String = "res://addons/region-editor/dragged_regions/%s.png" % get_parent().preview_name
	
	if not FileAccess.file_exists(image_path):
		await RenderingServer.frame_post_draw
		var image: Image = %DragPreview.get_texture().get_image()
		image.save_png(image_path)
		#await get_tree().process_frame
		filesystem.update_file(image_path)
		filesystem.reimport_files([image_path])
		await filesystem.resources_reimported
	#else:
		
	#filesystem.scan()
	#await get_tree().process_frame
	var drag_data: Dictionary = {
		"type": "files",
		"files": [image_path],
	}
	
	#var drag_preview: TextureRect = preview.duplicate()
	#drag_preview.size = Vector2(50, 50)
	#set_drag_preview(drag_preview)
	return drag_data
