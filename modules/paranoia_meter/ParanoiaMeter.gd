extends Node2D

@onready var aura: ColorRect = $AuraEffect
@onready var debug_console: CanvasLayer = $DebugConsole
@onready var decay_timer: Timer = $DecayTimer

var paranoia: int = 0
var dark_forest: bool = false
var lush_green: bool = false

func _ready() -> void:
    print("ParanoiaMeter ready")
    if debug_console:
        debug_console.visible = false
    decay_timer.timeout.connect(_on_decay_timer_timeout)

func change_paranoia(amount: int) -> void:
    paranoia = clamp(paranoia + amount, 0, 100)
    print("Paranoia changed to " + str(paranoia))
    if aura and aura.material:
        aura.material.set_shader_param("level", float(paranoia) / 100.0)

func set_environment(env: String, active: bool) -> void:
    if env == "dark_forest":
        dark_forest = active
        if active:
            lush_green = false
    elif env == "lush_green":
        lush_green = active
        if active:
            dark_forest = false

func _on_decay_timer_timeout() -> void:
    var delta := -1
    if dark_forest:
        delta += 5
    if lush_green:
        delta -= 5
    change_paranoia(delta)

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_F1:
            debug_console.visible = not debug_console.visible
            print("Debug console toggled: " + str(debug_console.visible))
