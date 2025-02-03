@tool
extends Button


func _get_drag_data(at_position: Vector2) -> Variant:
	var subviewport: SubViewport = $"../SubViewport"
	#var preview: 
	subviewport.size = $Preview.texture.get_size()
	subviewport.add_child($Preview.duplicate())
	await RenderingServer.frame_post_draw
	
	var image_path: String = "res://addons/region-editor/dragged_regions/%s.png" % get_parent().preview_name
	var image: Image = subviewport.get_texture().get_image()
	image.save_png(image_path)
	
	var drag_data: Dictionary = {
		"type": "files",
		"files": [image_path],
	}
	return drag_data
