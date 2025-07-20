extends Control

@onready var modules_list = $VBoxContainer/ModulesList

func _ready():
    print("LoadModule scene ready")
    print_debug("Debug: Reached _ready() in LoadModule.gd")
    $VBoxContainer/BackButton.pressed.connect(_on_back)
    _populate_modules()

func _populate_modules():
    var dir = DirAccess.open("res://modules")
    if dir:
        dir.list_dir_begin()
        var entry = dir.get_next()
        while entry != "":
            if entry == "." or entry == "..":
                entry = dir.get_next()
                continue
            if dir.current_is_dir():
                var metadata_path = "res://modules/" + entry + "/metadata.json"
                var module_name = entry
                if FileAccess.file_exists(metadata_path):
                    var file = FileAccess.open(metadata_path, FileAccess.READ)
                    if file:
                        var data = JSON.parse_string(file.get_as_text())
                        if typeof(data) == TYPE_DICTIONARY:
                            module_name = data.get("name", entry)
                var row = HBoxContainer.new()
                var label = Label.new()
                label.text = module_name
                var button = Button.new()
                button.text = "Load"
                button.pressed.connect(_on_load_button.bind(entry))
                row.add_child(label)
                row.add_child(button)
                modules_list.add_child(row)
            entry = dir.get_next()
        dir.list_dir_end()

func _on_load_button(module_dir):
    print("Load module: %s" % module_dir)

func _on_back():
    get_tree().change_scene_to_file("res://main/Main.tscn")
