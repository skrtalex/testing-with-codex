extends Control

@onready var list_container = $ScrollContainer/VBoxContainer

func _ready():
    var modules_dir = "res://modules"
    var dir = DirAccess.open(modules_dir)
    if dir:
        dir.list_dir_begin()
        var entry = dir.get_next()
        while entry != "":
            if dir.current_is_dir():
                var metadata_path = modules_dir + "/" + entry + "/metadata.json"
                if FileAccess.file_exists(metadata_path):
                    var file = FileAccess.open(metadata_path, FileAccess.READ)
                    if file:
                        var data = JSON.parse_string(file.get_as_text())
                        if typeof(data) == TYPE_DICTIONARY:
                            var name = data.get("name", entry)
                            var status = data.get("status", "Unknown")
                            var tags = data.get("tags", [])
                            var tags_text = ""
                            if tags is Array:
                                tags_text = ", ".join(tags)
                            else:
                                tags_text = str(tags)
                            var label = Label.new()
                            label.text = "%s - %s - %s" % [name, status, tags_text]
                            list_container.add_child(label)
            entry = dir.get_next()
        dir.list_dir_end()
