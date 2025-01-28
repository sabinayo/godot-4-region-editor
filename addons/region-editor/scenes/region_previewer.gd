@tool
class_name RegionEditorRegionPreviewer

extends Button

signal selected()

var data: Dictionary = {}


func set_data(new: Dictionary) -> void:
	data = new
	
	# Get the texture region
	var image: Image = sprite.texture.get_image().get_region(sprite.region_rect)
	preview.icon = ImageTexture.create_from_image(image)
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = load(data["base_texture"]) as Texture2D
	sprite.region_enabled = true
	sprite.region_rect = data["region_rect"]
	
	
	queue_free()


func _pressed() -> void:
	selected.emit(data)
