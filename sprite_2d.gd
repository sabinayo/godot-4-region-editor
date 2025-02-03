extends Node2D

enum Types {
	## ss
	REGION_RECT_1,
	## ss
	REGION_RECT_2,
}

enum RegionProperties {
	COLOR,
	RECT,
	COLLISION,
}

## 78
@export var type: Types = Types.REGION_RECT_1
