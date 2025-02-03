@tool
class_name RegionEditorRegionsExportDialog

extends ConfirmationDialog

## Export Dialog used to export a multiple regions.
## Queuefree once operation is canceled, succesful or not.[br]
## Add an instance to any node and activate it with the method 'set_data(regions_data: Array[Dictionary])').

signal export_canceled()
signal export_successful(path: String)

enum TipTypes {
	IMPORTANT, VERY_IMPORTANT,
}

const REGIONS_ENUM: PackedScene = preload("region_editor_regions_enum.tscn")
const REGION_PREVIEWER: PackedScene = preload("region_previewer.tscn")
const REGIONS_ENUM_EDITOR_DESCRIPTION: String = "Allow to select exported edited regions in 'Region Editor' through enumaration."
const TIP_ICONS: Dictionary = {
	TipTypes.IMPORTANT: preload("../icons/Warning.svg"),
	TipTypes.VERY_IMPORTANT: preload("../icons/Error.svg"),
}


var can_be_deleted: bool = false
var enum_base_texture: String = ""


func set_data(regions_data: Array[Dictionary]) -> void:
	enum_base_texture = regions_data[0]["base_texture"]
	%RegionPreviewerContainer.add_regions(regions_data)
	popup_centered()


func export_images(dir: String) -> void:
	pass


func _on_confirmed() -> void:
	match %ExportType.selected:
		0:
			var file_dialog: EditorFileDialog = EditorFileDialog.new()
			add_child(file_dialog)
			file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
			file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_ANY
			file_dialog.title = "Select Regions Destination Folder"
			file_dialog.popup_file_dialog()
			file_dialog.dir_selected.connect(
				func (dir: String) -> void:
					export_images(dir)
					file_dialog.queue_free()
			, CONNECT_ONE_SHOT)
			file_dialog.canceled.connect(
				func () -> void:
					file_dialog.queue_free()
			)
		
		1:
			var regions_enum: Sprite2D = Sprite2D.new()
			regions_enum.editor_description = REGIONS_ENUM_EDITOR_DESCRIPTION
			regions_enum.region_enabled = true
			
			# Avoid "scene/main/node.cpp:1311 - Condition "name.is_empty()" is true."
			if not %NodeName.text:
				regions_enum.name = "RegionEditorRegionsEnum"
			else:
				regions_enum.name = %NodeName.text
			
			regions_enum.texture = load(enum_base_texture)
			
			if %SaveEnumAsScene.button_pressed:
				var scene_name: String = %SceneName.text
				
				if not scene_name:
					scene_name = regions_enum.name.to_snake_case()
				
				var scene_path: String = scene_name
				
				if not %ScenePath.text.ends_with("/"):
					scene_path = "%s/%s" % [%ScenePath.text, scene_path]
				else:
					scene_path = %ScenePath.text + scene_path
				
				if not (scene_path.ends_with(".tscn")):
					scene_path += ".tscn"
				
				if %UseBuiltInScript.button_pressed:
					add_built_in_script_to_regions_enum(regions_enum)
				else:
					var script: GDScript = GDScript.new()
					script.source_code = get_region_enum_script_code()
					script.reload(true)
					
					var script_path: String = scene_path.trim_suffix(".tscn") + ".gd"
					ResourceSaver.save(script, script_path)
					regions_enum.set_script(load(script_path))
				
				var scene: PackedScene = PackedScene.new()
				scene.pack(regions_enum)
				ResourceSaver.save(scene, scene_path)
				
				if %AddEnumToCurrentScene.button_pressed:
					var current_scene = EditorInterface.get_edited_scene_root()
					
					if not current_scene:
						printerr("Region Editor: Attempt to add RegionsEnumNode to a null instance....")
						return
					
					var regions_enum_scene = load(scene_path).instantiate()
					current_scene.add_child(regions_enum_scene)
					regions_enum_scene.owner = current_scene
					EditorInterface.mark_scene_as_unsaved()
			
			elif %AddEnumToCurrentScene.button_pressed:
				add_built_in_script_to_regions_enum(regions_enum)
				var current_scene = EditorInterface.get_edited_scene_root()
				
				if not current_scene:
					printerr("Region Editor: Attempt to add RegionsEnumNode to a null instance....")
					return
				
				current_scene.add_child(regions_enum)
				regions_enum.owner = current_scene
				EditorInterface.mark_scene_as_unsaved()


func add_built_in_script_to_regions_enum(regions_enum: Sprite2D) -> void:
	var script: GDScript = GDScript.new()
	script.source_code = get_region_enum_script_code()
	script.reload(true)
	regions_enum.set_script(script)



func get_region_enum_script_code() -> String:
	var source_code: String = \
"""@tool
# Generated Script from RegionEditorPlugin. See https://sabinayo.github.com/

extends Sprite2D

# Add new values here.
enum {EnumName} {
	{EnumData}
}

# Properties below are used when a value of "{EnumName}" is selected.
enum RegionProperties {
	COLOR, # Type: Color. The color applied to the Sprite. See CanvasItem.self_modulate
	RECT, # Type: Rect2. The Rect2 defining the region to be applied to the sprite. See Sprite2D.region_rect
	COLLISION, # Type: PackedVector2Array. The collision polygon to use for collision detection. See CollisionPolygon2D.polygon
}

{EnumDescription}
@export var {EnumVarName}: {EnumName} = {EnumName}.{EnumFirstValue}:
	set(value):
		{EnumVarName} = value
		region_enabled = true
		region_rect = REGIONS[{EnumVarName}][RegionProperties.RECT]
		self_modulate = REGIONS[{EnumVarName}][RegionProperties.COLOR]

# Contain the properties to be applied to the sprite for each value of "{EnumName}".
# If you add a new value to "{EnumName}", be sure to add here the properties to be applied to the sprite.
# Syntax: { RegionProperties.X: Value }
const REGIONS: Dictionary = {
	{RegionsData}
}

"""
	var regions_data: Array[Dictionary] = %RegionPreviewerContainer.get_regions_data()
	var enum_data: String = ""
	var enum_first_value: String = ""
	var regions_enum_data: String = ""
	
	var enum_value_id: int = 0
	
	for data: Dictionary in regions_data:
		# convert each name to: THIS_FORMAT
		var enum_value: String = data["name"]
		
		if not enum_value:
			enum_value = "RegionRect_%s" % enum_value_id
		
		enum_value = enum_value.strip_edges().to_snake_case()
		enum_value = enum_value.to_upper()
		
		if enum_value_id == 0:
			enum_first_value = enum_value
		
		# add '##' only if non empty description
		var enum_value_description: String = data.get("description", "")
		
		if enum_value_description:
			enum_value_description = "## %s" % enum_value_description
		
		var new_enum_data: String = \
"""{EnumValueDescription}
	{EnumValue},
	""".format({
		"EnumValue": enum_value,
		"EnumValueDescription": enum_value_description,
	})
		if not enum_value_description:
			new_enum_data = new_enum_data.trim_prefix("\n\t")
		
		enum_data += new_enum_data
		
		regions_enum_data += \
"""Types.{EnumValue}: {
		RegionProperties.COLOR: {RegionColor},
		RegionProperties.RECT: {RegionRect},
	},
	""".format({
			"EnumValue": enum_value,
			"RegionColor": var_to_str(data["modulate"]),
			"RegionRect": var_to_str(data["region_rect"])
		})
		enum_value_id += 1
	
	var enum_name: String = %EnumName.text
	var enum_var_name: String = enum_name.to_camel_case()
	
	if not enum_name:
		enum_name = "Types"
		enum_var_name = "type"
	
	# add '##' only if not empty description
	var enum_description: String = %RegionsEnumDescription.text
	
	if enum_description:
		enum_description = "## %s" % enum_description
	
	source_code = source_code.format({
		"EnumDescription": enum_description,
		"EnumName": enum_name,
		"EnumData": enum_data,
		"EnumVarName": enum_var_name,
		"EnumFirstValue": enum_first_value,
		"RegionsData": regions_enum_data,
	})
	
	return source_code


func _on_canceled() -> void:
	export_canceled.emit()
	queue_free()


func _on_region_previewer_container_region_deleted(was_edited: bool, region_id: int) -> void:
	if %RegionPreviewerContainer.region_count == 0:
		get_ok_button().disabled = true


func _on_select_enumaration_scene_path_pressed() -> void:
	var file_dialog: EditorFileDialog = EditorFileDialog.new()
	add_child(file_dialog)
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	file_dialog.title = "Select Enumaration Scene Destination Folder"
	file_dialog.popup_file_dialog()
	file_dialog.dir_selected.connect(
		func (dir: String) -> void:
			%ScenePathCont.tooltip_text = dir
			%ScenePath.text = dir
			file_dialog.queue_free()
	, CONNECT_ONE_SHOT)
	file_dialog.canceled.connect(
		func () -> void:
			file_dialog.queue_free()
	)


func _on_add_enum_description_pressed() -> void:
	%DescriptionEdit.popup_centered()


func show_tip(type: TipTypes, text: String, time: float = 0.0) -> void:
	%Tip.show()
	%TipIcon.texture = TIP_ICONS[type]
	%TipLabel.text = text
	
	if time > 0.0:
		if not %TipTimer.is_stopped():
			%TipTimer.stop()
		
		%TipTimer.start(time)


func _on_tip_timer_timeout() -> void:
	%Tip.hide()


func _on_export_type_item_selected(index: int) -> void:
	if index == 1:
		%RegionPreviewerContainer.change_region_edition_type(RegionEditorRegionPreviewer.EditionTypes.DESCRIPTION)
		show_tip(TipTypes.IMPORTANT, "(Click Regions to edit their description)")
	else:
		%Tip.hide()
		%RegionPreviewerContainer.change_region_edition_type(RegionEditorRegionPreviewer.EditionTypes.DISABLED)
