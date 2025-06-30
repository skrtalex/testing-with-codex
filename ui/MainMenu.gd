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

    main_screen_container = get_node_or_null("..")
    if main_screen_container == null:
        push_error("MainScreenContainer node not found!")
        return
    print("MainScreenContainer found")

    new_module_button.pressed.connect(_on_new_module)
    load_module_button.pressed.connect(_on_load_module)
    view_modules_button.pressed.connect(_on_view_all_modules)
    settings_button.pressed.connect(_on_settings)

func clear_children(node: Node) -> void:
    for child in node.get_children():
        child.queue_free()

func _load_into_container(scene_path: String) -> void:
    if not main_screen_container:
        push_error("No container available to load scene: " + scene_path)
        return

    var scene_res = load(scene_path)
    if scene_res == null or not (scene_res is PackedScene):
        push_error("Failed to load: " + scene_path)
        return

    clear_children(main_screen_container)
    var instance = scene_res.instantiate()
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
