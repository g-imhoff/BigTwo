extends Resource
class_name SaveData

@export var username: String = ""
@export var connection_token: String = ""

func save_to_disk(path: String = "user://save_data.tres") -> void:
	ResourceSaver.save(self, path)
	
static func load_or_create(path: String = "user://save_data.tres") -> SaveData:
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path) as SaveData
	else:
		# Create a new instance if no save file exists
		var new_save = SaveData.new()
		return new_save
