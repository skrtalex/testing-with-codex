extends CanvasLayer

@onready var gunshot_button: Button = $Panel/VBoxContainer/GunshotButton
@onready var alone_button: Button = $Panel/VBoxContainer/AloneButton
@onready var calming_pills_button: Button = $Panel/VBoxContainer/CalmingPillsButton
@onready var warm_tea_button: Button = $Panel/VBoxContainer/WarmTeaButton
@onready var dark_forest_check: CheckBox = $Panel/VBoxContainer/DarkForest
@onready var lush_green_check: CheckBox = $Panel/VBoxContainer/LushGreen

func _ready() -> void:
    print("DebugConsole ready")
    gunshot_button.pressed.connect(_on_gunshot)
    alone_button.pressed.connect(_on_alone)
    calming_pills_button.pressed.connect(_on_pills)
    warm_tea_button.pressed.connect(_on_tea)
    dark_forest_check.toggled.connect(_on_dark_forest)
    lush_green_check.toggled.connect(_on_lush_green)

func _trigger(amount: int) -> void:
    var parent_scene = get_parent()
    if parent_scene and parent_scene.has_method("change_paranoia"):
        parent_scene.change_paranoia(amount)
    else:
        push_warning("Parent scene missing change_paranoia")

func _on_gunshot() -> void:
    _trigger(20)

func _on_alone() -> void:
    _trigger(10)

func _on_pills() -> void:
    _trigger(-20)

func _on_tea() -> void:
    _trigger(-10)

func _on_dark_forest(pressed: bool) -> void:
    if pressed:
        lush_green_check.button_pressed = false
    var parent_scene = get_parent()
    if parent_scene and parent_scene.has_method("set_environment"):
        parent_scene.set_environment("dark_forest", pressed)

func _on_lush_green(pressed: bool) -> void:
    if pressed:
        dark_forest_check.button_pressed = false
    var parent_scene = get_parent()
    if parent_scene and parent_scene.has_method("set_environment"):
        parent_scene.set_environment("lush_green", pressed)
