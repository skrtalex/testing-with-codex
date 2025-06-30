extends Control

func _ready():
    $VBoxContainer/BackButton.pressed.connect(_on_back)

func _on_back():
    get_tree().change_scene_to_file("res://main/Main.tscn")
