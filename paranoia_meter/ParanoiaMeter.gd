extends Node2D

var paranoia: float = 0.0
var dark_forest: bool = false
var lush_green: bool = false

var _timer: float = 0.0

func _ready():
    print("ParanoiaMeter ready")
    var console = get_node_or_null("DebugConsole")
    if console:
        console.visible = false
    else:
        print("DebugConsole not found")

func _process(delta: float) -> void:
    _timer += delta
    if _timer >= 5.0:
        change_paranoia(-1)
        if dark_forest:
            change_paranoia(5)
        if lush_green:
            change_paranoia(-5)
        _timer = 0.0
    update_shader()

func _input(event):
    if event is InputEventKey and event.pressed and event.keycode == Key.F1:
        var console = get_node_or_null("DebugConsole")
        if console:
            console.visible = not console.visible
            print("Debug console toggled ", console.visible)

func change_paranoia(amount: float) -> void:
    paranoia = clamp(paranoia + amount, 0.0, 100.0)
    print("Paranoia changed by", amount, "new value", paranoia)
    update_shader()

func update_shader():
    var aura = get_node_or_null("AuraEffect")
    if aura and aura.material:
        aura.material.set_shader_parameter("level", paranoia / 100.0)
