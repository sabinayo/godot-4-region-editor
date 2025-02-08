@tool
# Generated Script from RegionEditorPlugin. See https://github.com/sabinayo/godot-region-editor

extends Sprite2D

# Add new values here.
enum Types {
	REGION_RECT_1,
	REGION_RECT_2,
	
}

# Properties below are used when a value of "Types" is selected.
enum RegionProperties {
	COLOR, # Type: Color. The color applied to the Sprite. See CanvasItem.self_modulate
	RECT, # Type: Rect2. The Rect2 defining the region to be applied to the sprite. See Sprite2D.region_rect
	COLLISION, # Type: PackedVector2Array. The collision polygon to use for collision detection. See CollisionPolygon2D.polygon
}


@export var type: Types = Types.REGION_RECT_1:
	set(value):
		type = value
		region_enabled = true
		region_rect = REGIONS[type][RegionProperties.RECT]
		self_modulate = REGIONS[type][RegionProperties.COLOR]

# Contain the properties to be applied to the sprite for each value of "Types".
# If you add a new value to "Types", be sure to add here the properties to be applied to the sprite.
# Syntax: { RegionProperties.X: Value }
const REGIONS: Dictionary = {
	Types.REGION_RECT_1: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1604, 401, 1140, 512),
	},
	Types.REGION_RECT_2: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(2893, 9, 1053, 915),
	},
	
}

