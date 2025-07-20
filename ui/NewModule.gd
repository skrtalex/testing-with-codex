extends Control

@onready var name_edit = $VBoxContainer/NameEdit
@onready var description_edit = $VBoxContainer/DescriptionEdit
@onready var tags_edit = $VBoxContainer/TagsEdit
@onready var status_dropdown = $VBoxContainer/StatusDropdown

func _ready():
    print("NewModule _ready")
    $VBoxContainer/CreateButton.pressed.connect(_on_create)
    $VBoxContainer/BackButton.pressed.connect(_on_back)
    status_dropdown.add_item("In Work")
    status_dropdown.add_item("Finished")

func _on_create():
    var module_name = name_edit.text.strip_edges()
    if module_name == "":
        return
    var folder_name = module_name.to_lower().replace(" ", "_")
    var dir = DirAccess.open("res://")
    if dir:
        if dir.dir_exists("modules/" + folder_name):
            push_error("Module folder already exists: " + folder_name)
            print("Module folder already exists: " + folder_name)
            return
        var err = dir.make_dir("modules/" + folder_name)
        if err != OK:
            push_error("Failed to create directory: " + folder_name)
            print("Failed to create directory: " + folder_name)
            return

    var module_path = "res://modules/" + folder_name
    var metadata = {
        "name": module_name,
        "description": description_edit.text,
        "tags": tags_edit.text.split(",", false),
        "status": status_dropdown.get_item_text(status_dropdown.selected),
        "author": "",
        "version": "0.1"
    }
    var meta_file = FileAccess.open(module_path + "/metadata.json", FileAccess.WRITE)
    if meta_file:
        meta_file.store_string(JSON.new().stringify(metadata, "\t"))
        meta_file.close()

    var scene_file = FileAccess.open(module_path + "/Module.tscn", FileAccess.WRITE)
    if scene_file:
        scene_file.store_string("[gd_scene load_steps=1 format=3]\n\n[node name=\"Module\" type=\"Node\"]")
        scene_file.close()

    print("Created module: " + module_name)
    get_tree().change_scene_to_file("res://main/Main.tscn")

func _on_back():
    get_tree().change_scene_to_file("res://main/Main.tscn")
