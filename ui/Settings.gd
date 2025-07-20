extends Control

func _ready():
    print("Settings scene ready")
    print_debug("Debug: Reached _ready() in Settings.gd")
    $VBoxContainer/BackButton.pressed.connect(_on_back)

func _on_back():
    get_tree().change_scene_to_file("res://main/Main.tscn")
