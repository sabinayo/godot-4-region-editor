
@tool
extends Sprite2D

enum Types {
	RegionRect_1,RegionRect_2,RegionRect_3,RegionRect_4,RegionRect_5,RegionRect_6,RegionRect_7,RegionRect_8,RegionRect_9,RegionRect_10,RegionRect_11,
}

enum RegionProperties {
	COLOR,
	RECT,
	COLLISION,
}

@export var type: Types:
	set(value):
		type = value
		region_rect = REGIONS[type][RegionProperties.RECT]
		self_modulate = REGIONS[type][RegionProperties.COLOR]

const REGIONS: Dictionary = {
	
Types.RegionRect_1: {
	RegionProperties.COLOR: Color(1, 1, 1, 1),
	RegionProperties.RECT: Rect2(2893, 9, 1053, 915),
},

Types.RegionRect_2: {
	RegionProperties.COLOR: Color(1, 1, 1, 1),
	RegionProperties.RECT: Rect2(233, 192, 1283, 706),
},

Types.RegionRect_3: {
	RegionProperties.COLOR: Color(1, 1, 1, 1),
	RegionProperties.RECT: Rect2(1604, 401, 1140, 512),
},

Types.RegionRect_4: {
	RegionProperties.COLOR: Color(1, 1, 1, 1),
	RegionProperties.RECT: Rect2(125, 962, 1473, 626),
},

Types.RegionRect_5: {
	RegionProperties.COLOR: Color(1, 1, 1, 1),
	RegionProperties.RECT: Rect2(2066, 972, 1225, 808),
},

Types.RegionRect_6: {
	RegionProperties.COLOR: Color(1, 1, 1, 1),
	RegionProperties.RECT: Rect2(435, 1635, 917, 850),
},

Types.RegionRect_7: {
	RegionProperties.COLOR: Color(1, 1, 1, 1),
	RegionProperties.RECT: Rect2(97, 2640, 289, 258),
},

Types.RegionRect_8: {
	RegionProperties.COLOR: Color(1, 1, 1, 1),
	RegionProperties.RECT: Rect2(2113, 2566, 412, 1465),
},

Types.RegionRect_9: {
	RegionProperties.COLOR: Color(1, 1, 1, 1),
	RegionProperties.RECT: Rect2(2608, 2564, 426, 1473),
},

Types.RegionRect_10: {
	RegionProperties.COLOR: Color(1, 1, 1, 1),
	RegionProperties.RECT: Rect2(3109, 2561, 420, 1480),
},

Types.RegionRect_11: {
	RegionProperties.COLOR: Color(1, 1, 1, 1),
	RegionProperties.RECT: Rect2(3721, 2547, 246, 1503),
},

}
