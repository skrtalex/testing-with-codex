extends Control

const NEW_MODULE_SCENE := preload("res://ui/NewModule.tscn")
const LOAD_MODULE_SCENE := preload("res://ui/LoadModule.tscn")
const VIEW_MODULES_SCENE := preload("res://ui/ViewModules.tscn")
const SETTINGS_SCENE := preload("res://ui/Settings.tscn")

@onready var main_screen_container: Control = get_parent().get_node("MainScreenContainer")

func _ready() -> void:
    $VBoxContainer/NewModuleButton.pressed.connect(_on_new_module)
    $VBoxContainer/LoadModuleButton.pressed.connect(_on_load_module)
    $VBoxContainer/ViewAllModulesButton.pressed.connect(_on_view_all_modules)
    $VBoxContainer/SettingsButton.pressed.connect(_on_settings)

func _clear_container() -> void:
    for child in main_screen_container.get_children():
        child.queue_free()

func _load_into_container(scene: PackedScene) -> void:
    _clear_container()
    var instance = scene.instantiate()
    main_screen_container.add_child(instance)
    if instance is Control:
        instance.anchor_left = 0.0
        instance.anchor_top = 0.0
        instance.anchor_right = 1.0
        instance.anchor_bottom = 1.0

func _on_new_module() -> void:
    _load_into_container(NEW_MODULE_SCENE)

func _on_load_module() -> void:
    _load_into_container(LOAD_MODULE_SCENE)

func _on_view_all_modules() -> void:
    _load_into_container(VIEW_MODULES_SCENE)

func _on_settings() -> void:
    _load_into_container(SETTINGS_SCENE)
