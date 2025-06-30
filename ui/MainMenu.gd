extends Control

func _ready():
    $VBoxContainer/NewModuleButton.pressed.connect(_on_new_module)
    $VBoxContainer/LoadModuleButton.pressed.connect(_on_load_module)
    $VBoxContainer/ViewAllModulesButton.pressed.connect(_on_view_all_modules)
    $VBoxContainer/SettingsButton.pressed.connect(_on_settings)

func _on_new_module():
    get_tree().change_scene_to_file("res://ui/NewModule.tscn")

func _on_load_module():
    get_tree().change_scene_to_file("res://ui/LoadModule.tscn")

func _on_view_all_modules():
    get_tree().change_scene_to_file("res://ui/ViewModules.tscn")

func _on_settings():
    get_tree().change_scene_to_file("res://ui/Settings.tscn")
