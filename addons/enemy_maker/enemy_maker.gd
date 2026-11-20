@tool
extends EditorPlugin

const ENEMY_RESOURCES_DIRECTORY: String = "res://Resources/EnemySources/"
const ENEMY_REGISTERY_SAVE_PATH: String = "res://Resources/enemy_registry.tres"
var plugin_button: Button

func _enter_tree() -> void:
	plugin_button = Button.new()
	plugin_button.text = "Make Enemies"
	plugin_button.pressed.connect(_on_plugin_button_pressed)
	
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, plugin_button)

func _exit_tree() -> void:
	if is_instance_valid(plugin_button):
		remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, plugin_button)
		plugin_button.queue_free()

func _on_plugin_button_pressed() -> void:
	print_rich("[color=blue]Loading enemy data resources...")
	var enemy_registry: EnemyRegistry = EnemyRegistry.new()
	
	var files: PackedStringArray = DirAccess.get_files_at(ENEMY_RESOURCES_DIRECTORY)
	for file in files:
		if file.get_extension() != "tres":
			continue
		var enemy_source: EnemyData = load(ENEMY_RESOURCES_DIRECTORY + file) as EnemyData
		if enemy_source == null:
			continue
		if enemy_registry.enemies.has(enemy_source.enemy_id):
			push_error("DUPLICATE ENTRY FOUND FOR ", file, " ", enemy_source.enemy_id, " IT WILL BE SKIPPED")
			continue
		enemy_registry.enemies[enemy_source.enemy_id] = enemy_source
	print(ResourceSaver.save(enemy_registry, ENEMY_REGISTERY_SAVE_PATH))
	print_rich("[color=green]Loaded ", enemy_registry.enemies.size(), " enemies into registry.")
