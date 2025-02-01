@tool
class_name RegionEditorRegionsExportDialog

extends ConfirmationDialog

## Export Dialog used to export a multiple regions.
## Queuefree once operation is canceled, succesful or not.[br]
## Add an instance to any node and activate it with the method 'set_data(regions_data: Array[Dictionary])').

signal export_canceled()
signal export_successful(path: String)


const REGIONS_ENUM: PackedScene = preload("region_editor_regions_enum.tscn")
const REGION_PREVIEWER: PackedScene = preload("region_previewer.tscn")

var enum_base_texture: String = ""


func set_data(regions_data: Array[Dictionary]) -> void:
	enum_base_texture = regions_data[0]["base_texture"]
	%RegionPreviewerContainer.add_regions(regions_data)
	popup_centered()


func export(path: String) -> void:
	export_successful.emit(path)
	queue_free()


func _on_confirmed() -> void:
	match %ExportType.selected:
		0:
			var file_dialog: EditorFileDialog = EditorFileDialog.new()
			add_child(file_dialog)
			file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
			file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
			file_dialog.title = "Select Regions Destination Folder"
			file_dialog.popup_file_dialog()
			file_dialog.dir_selected.connect(
				func (dir: String) -> void:
					
					file_dialog.queue_free()
			, CONNECT_ONE_SHOT)
			file_dialog.canceled.connect(
				func () -> void:
					file_dialog.queue_free()
			)
		
		1:
			#get_region_enum_script_code()
			#return
			var current_scene = get_tree().edited_scene_root
			
			if not current_scene:
				return
			
			var region_enum = REGIONS_ENUM.instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
			current_scene.add_child(region_enum)
			region_enum.texture = load(enum_base_texture)
			region_enum.owner = current_scene
			var script: GDScript = region_enum.get_script()
			script.source_code = get_region_enum_script_code()
			script.reload(true)


func get_region_enum_script_code() -> String:
	var source_code: String = \
	"""
	@tool
	extends Sprite2D
	
	enum Types {
		%s
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
		%s
	}
	""".dedent()
	var regions_data: Array[Dictionary] = %RegionPreviewerContainer.get_regions_data()
	var enum_data: String = ""
	var regions_enum_data: String = ""
	
	for data: Dictionary in regions_data:
		enum_data += "%s," % data["name"]
		
		regions_enum_data += """
		Types.%s: {
			RegionProperties.COLOR: %s,
			RegionProperties.RECT: %s,
		},
		""".dedent() % [
			data["name"],
			var_to_str(data["modulate"]),
			var_to_str(data["region_rect"])
		]
	
	source_code %= [
		enum_data,
		regions_enum_data
	]
	print(source_code.strip_edges(true, true))
	
	return source_code



func _on_canceled() -> void:
	export_canceled.emit()
	queue_free()


func _on_region_previewer_container_region_deleted(was_edited: bool, region_id: int) -> void:
	if %RegionPreviewerContainer.region_count == 0:
		get_ok_button().disabled = true
