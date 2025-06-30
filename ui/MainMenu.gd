extends Control

const NEW_MODULE_PATH := "res://ui/NewModule.tscn"
const LOAD_MODULE_PATH := "res://ui/LoadModule.tscn"
const VIEW_MODULES_PATH := "res://ui/ViewModules.tscn"
const SETTINGS_PATH := "res://ui/Settings.tscn"

@onready var new_module_button: Button = $VBoxContainer/NewModuleButton
@onready var load_module_button: Button = $VBoxContainer/LoadModuleButton
@onready var view_modules_button: Button = $VBoxContainer/ViewAllModulesButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton

var main_screen_container: Control

func _ready() -> void:
	print("MainMenu is READY")
	print_debug("Debug: Reached _ready() in MainMenu.gd")
	push_warning("If you see this, script is executing.")

	main_screen_container = get_parent().get_node_or_null("MainScreenContainer")
	if main_screen_container == null:
		push_error("MainScreenContainer node not found!")
	else:
		print("MainScreenContainer found")

	new_module_button.pressed.connect(_on_new_module)
	load_module_button.pressed.connect(_on_load_module)
	view_modules_button.pressed.connect(_on_view_all_modules)
	settings_button.pressed.connect(_on_settings)

func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func _load_into_container(scene_path: String) -> void:
	clear_children(main_screen_container)
	var instance = load(scene_path).instantiate()
	main_screen_container.add_child(instance)
	if instance is Control:
		instance.anchor_left = 0.0
		instance.anchor_top = 0.0
		instance.anchor_right = 1.0
		instance.anchor_bottom = 1.0

func _on_new_module() -> void:
	print("New Module button pressed")
	_load_into_container(NEW_MODULE_PATH)

func _on_load_module() -> void:
	print("Load Module button pressed")
	_load_into_container(LOAD_MODULE_PATH)

func _on_view_all_modules() -> void:
	print("View All Modules button pressed")
	_load_into_container(VIEW_MODULES_PATH)

func _on_settings() -> void:
	print("Settings button pressed")
	_load_into_container(SETTINGS_PATH)
