class_name GameConfig
extends RefCounted

const CONFIG_PATH := "res://data/game_config.json"

static func load_data() -> Dictionary:
    if not FileAccess.file_exists(CONFIG_PATH):
        push_error("Missing config file: %s" % CONFIG_PATH)
        return {}

    var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
    if file == null:
        push_error("Could not open config file: %s" % CONFIG_PATH)
        return {}

    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("game_config.json is invalid or is not a JSON object.")
        return {}

    return parsed
