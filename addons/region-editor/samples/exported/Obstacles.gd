@tool
# Generated Script from RegionEditorPlugin. See https://github.com/sabinayo/godot-4-region-editor

extends Sprite2D

# Add new values here.
enum Obstacles {
	REGION_RECT_1,
	REGION_RECT_2,
	REGION_RECT_3,
	REGION_RECT_4,
	REGION_RECT_5,
	REGION_RECT_6,
	REGION_RECT_7,
	REGION_RECT_8,
	REGION_RECT_9,
	REGION_RECT_10,
	REGION_RECT_11,
	REGION_RECT_12,
	REGION_RECT_13,
	REGION_RECT_14,
	REGION_RECT_15,
	REGION_RECT_16,
	REGION_RECT_17,
	REGION_RECT_18,
	REGION_RECT_19,
	REGION_RECT_20,
	REGION_RECT_21,
	REGION_RECT_22,
	REGION_RECT_23,
	REGION_RECT_24,
	REGION_RECT_25,
	REGION_RECT_26,
	REGION_RECT_27,
	REGION_RECT_28,
	REGION_RECT_29,
	REGION_RECT_30,
	
}

# Properties below are used when a value of "Obstacles" is selected.
enum RegionProperties {
	COLOR, # Type: Color. The color applied to the Sprite. See CanvasItem.self_modulate
	RECT, # Type: Rect2. The Rect2 defining the region to be applied to the sprite. See Sprite2D.region_rect
	COLLISION, # Type: PackedVector2Array. The collision polygon to use for collision detection. See CollisionPolygon2D.polygon
}


@export var obstacles: Obstacles = Obstacles.REGION_RECT_1:
	set(value):
		obstacles = value
		region_enabled = true
		region_rect = REGIONS[obstacles][RegionProperties.RECT]
		self_modulate = REGIONS[obstacles][RegionProperties.COLOR]

# Contain the properties to be applied to the sprite for each value of "Obstacles".
# If you add a new value to "Obstacles", be sure to add here the properties to be applied to the sprite.
# Syntax: { RegionProperties.X: Value }
const REGIONS: Dictionary = {
	Obstacles.REGION_RECT_1: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(233, 192, 1283, 706),
	},
	Obstacles.REGION_RECT_2: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1604, 401, 1140, 512),
	},
	Obstacles.REGION_RECT_3: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(2893, 9, 1053, 915),
	},
	Obstacles.REGION_RECT_4: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(125, 962, 1473, 626),
	},
	Obstacles.REGION_RECT_5: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(2066, 972, 1225, 808),
	},
	Obstacles.REGION_RECT_6: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(435, 1635, 917, 850),
	},
	Obstacles.REGION_RECT_7: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1665, 1893, 456, 423),
	},
	Obstacles.REGION_RECT_8: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(2344, 1892, 609, 402),
	},
	Obstacles.REGION_RECT_9: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(3164, 1939, 740, 315),
	},
	Obstacles.REGION_RECT_10: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(97, 2640, 289, 258),
	},
	Obstacles.REGION_RECT_11: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(657, 2626, 273, 378),
	},
	Obstacles.REGION_RECT_12: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(87, 3077, 335, 440),
	},
	Obstacles.REGION_RECT_13: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(618, 3180, 299, 227),
	},
	Obstacles.REGION_RECT_14: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(220, 3586, 99, 449),
	},
	Obstacles.REGION_RECT_15: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(575, 3573, 254, 475),
	},
	Obstacles.REGION_RECT_16: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(882, 3645, 60, 397),
	},
	Obstacles.REGION_RECT_17: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1235, 2630, 150, 359),
	},
	Obstacles.REGION_RECT_18: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1170, 3104, 171, 407),
	},
	Obstacles.REGION_RECT_19: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1259, 3633, 83, 394),
	},
	Obstacles.REGION_RECT_20: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1426, 2936, 138, 174),
	},
	Obstacles.REGION_RECT_21: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1580, 2735, 131, 167),
	},
	Obstacles.REGION_RECT_22: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1729, 2741, 133, 174),
	},
	Obstacles.REGION_RECT_23: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1878, 2772, 62, 132),
	},
	Obstacles.REGION_RECT_24: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1948, 2761, 71, 146),
	},
	Obstacles.REGION_RECT_25: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1600, 3074, 401, 446),
	},
	Obstacles.REGION_RECT_26: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(1600, 3619, 365, 398),
	},
	Obstacles.REGION_RECT_27: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(2113, 2566, 412, 1465),
	},
	Obstacles.REGION_RECT_28: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(2608, 2564, 426, 1473),
	},
	Obstacles.REGION_RECT_29: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(3109, 2561, 420, 1480),
	},
	Obstacles.REGION_RECT_30: {
		RegionProperties.COLOR: Color(1, 1, 1, 1),
		RegionProperties.RECT: Rect2(3721, 2547, 246, 1503),
	},
	
}
