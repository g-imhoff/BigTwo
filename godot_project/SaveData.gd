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

static func clear_all_saves() -> void:
	var save_path = "user://save_data.tres"
	
	# Accéder au dossier utilisateur
	var dir = DirAccess.open("user://")
	if not dir:
		push_error("Impossible d'accéder au dossier user://")
		return
	
	# Vérifier et supprimer le fichier
	if dir.file_exists(save_path):
		var error = dir.remove(save_path)
		if error != OK:
			push_error("Échec de la suppression : ", save_path, " | Erreur: ", error)
		else:
			print("Sauvegarde supprimée avec succès")
	else:
		print("Aucune sauvegarde trouvée")
