extends Node2D

var aura
var debug_console

var paranoia := 0.0
var max_paranoia := 100.0
var decay_timer := 0.0
var base_decay := -1.0
var decay_interval := 5.0
var dark_forest := false
var lush_green := false

func _ready():
    aura = get_node_or_null("AuraEffect")
    debug_console = get_node_or_null("DebugConsole")
    if aura:
        print("ParanoiaMeter: AuraEffect found")
    else:
        print("ParanoiaMeter: AuraEffect missing")
    if debug_console:
        print("ParanoiaMeter: DebugConsole found")
    else:
        print("ParanoiaMeter: DebugConsole missing")
    if debug_console:
        _connect_debug_console_signals(debug_console)
        debug_console.visible = false
    print("ParanoiaMeter ready")

func _connect_debug_console_signals(dc):
    var vb = dc.get_node_or_null("Panel/VBoxContainer")
    if not vb:
        return
    var gun = vb.get_node_or_null("Gunshot (+20)")
    if gun:
        gun.pressed.connect(dc._on_Gunshot_pressed)
    var alone = vb.get_node_or_null("Alone Too Long (+10)")
    if alone:
        alone.pressed.connect(dc._on_Alone_pressed)
    var pills = vb.get_node_or_null("Calming Pills (-20)")
    if pills:
        pills.pressed.connect(dc._on_Pills_pressed)
    var tea = vb.get_node_or_null("Warm Tea (-10)")
    if tea:
        tea.pressed.connect(dc._on_Tea_pressed)
    var df = vb.get_node_or_null("Dark Forest")
    if df:
        df.toggled.connect(dc._on_DarkForest_toggled)
    var lg = vb.get_node_or_null("Lush Green")
    if lg:
        lg.toggled.connect(dc._on_LushGreen_toggled)

func _process(delta: float) -> void:
    decay_timer += delta
    if decay_timer >= decay_interval:
        decay_timer = 0.0
        var change = base_decay
        if dark_forest:
            change = 5.0
        if lush_green:
            change = -5.0
        change_paranoia(change)

func change_paranoia(amount: float) -> void:
    paranoia = clamp(paranoia + amount, 0.0, max_paranoia)
    update_aura()
    print("Paranoia changed to: ", paranoia)

func update_aura() -> void:
    if aura and aura.material and aura.material.has_shader_param("level"):
        aura.material.set_shader_param("level", paranoia / max_paranoia)

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        if debug_console:
            debug_console.visible = !debug_console.visible
