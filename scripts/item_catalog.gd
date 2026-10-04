class_name ItemCatalog
extends RefCounted

var definitions: Dictionary = {}
var icons: Dictionary = {}

func _init() -> void:
    var file := FileAccess.open("res://data/items.json", FileAccess.READ)
    if file == null:
        push_error("Cannot open item catalog")
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary:
        push_error("Item catalog must be a JSON object")
        return
    for id in parsed:
        var entry: Dictionary = parsed[id]
        var icon := load(str(entry.get("icon", ""))) as Texture2D
        if icon == null or int(entry.get("max_stack", 0)) < 1:
            push_error("Invalid item definition: %s" % id)
            continue
        definitions[id] = entry
        icons[id] = icon

func has_item(id: String) -> bool:
    return definitions.has(id)

func stack_limit(id: String) -> int:
    return int(definitions.get(id, {}).get("max_stack", 0))

func display_name(id: String) -> String:
    return str(definitions.get(id, {}).get("display_name", id))

func icon(id: String) -> Texture2D:
    return icons.get(id) as Texture2D
