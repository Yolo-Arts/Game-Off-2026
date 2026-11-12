extends Node

#signal outdated_save_detected
signal data_loaded
signal data_saved

const SAVE_DATA_PATH = "user://save_file.res"

var data: SaveData


func _ready() -> void :
	load_data()



func load_data() -> void :
	if !ResourceLoader.exists(SAVE_DATA_PATH):
		reset_save_data()
		return
	
	data = ResourceLoader.load(SAVE_DATA_PATH) as SaveData
	data_loaded.emit()


func save_data() -> void :
	data_saved.emit()
	ResourceSaver.save(data, SAVE_DATA_PATH, 32)

func reset_save_data() -> void :
	print("Data Reset D: ")
	data = SaveData.new()
	data.application_version = ProjectSettings.get_setting("application/config/version")
	data_loaded.emit()

func _exit_tree():
	save_data()
