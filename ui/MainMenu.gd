extends Control

func _ready():
    $VBoxContainer/NewModuleButton.pressed.connect(_on_new_module)
    $VBoxContainer/LoadModuleButton.pressed.connect(_on_load_module)
    $VBoxContainer/ViewAllModulesButton.pressed.connect(_on_view_all_modules)
    $VBoxContainer/SettingsButton.pressed.connect(_on_settings)

func _on_new_module():
    print("New Module clicked")

func _on_load_module():
    print("Load Module clicked")

func _on_view_all_modules():
    print("View All Modules clicked")

func _on_settings():
    print("Settings clicked")
