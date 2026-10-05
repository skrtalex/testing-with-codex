class_name TestMenu
extends CanvasLayer

signal command_requested(command: String)
signal open_changed(open: bool)

var panel: PanelContainer
var tabs: TabContainer
var is_open := false
var reset_button: Button
var status: Label
var infinite_button: Button
var diagnostics_button: Button
var footprints_button: Button
var skin_button: Button
var confirm_reset := false

func _ready() -> void:
    layer = 20
    process_mode = Node.PROCESS_MODE_ALWAYS
    var shade := ColorRect.new()
    shade.name = "Shade"
    shade.color = Color(0.03, 0.05, 0.03, 0.65)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)
    panel = PanelContainer.new()
    add_child(panel)
    var style := StyleBoxFlat.new()
    style.bg_color = Color("243326")
    style.border_color = Color("a6bb83")
    style.set_border_width_all(2)
    style.set_corner_radius_all(6)
    style.content_margin_left = 16
    style.content_margin_right = 16
    style.content_margin_top = 14
    style.content_margin_bottom = 14
    panel.add_theme_stylebox_override("panel", style)
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 10)
    panel.add_child(content)
    var heading := Label.new()
    heading.text = "TEST MENU   ·   Gameplay paused"
    content.add_child(heading)
    tabs = TabContainer.new()
    content.add_child(tabs)
    var debug := VBoxContainer.new()
    debug.name = "Debug"
    debug.add_theme_constant_override("separation", 6)
    tabs.add_child(debug)
    infinite_button = _button(debug, "", "infinite")
    skin_button = _button(debug, "", "skin")
    diagnostics_button = _button(debug, "", "diagnostics")
    footprints_button = _button(debug, "", "footprints")
    _button(debug, "Refill stamina", "refill")
    _button(debug, "Return to arrival point", "spawn")
    reset_button = _button(debug, "Reset current test area…", "reset")
    var controls := Label.new()
    controls.name = "Keybinds"
    controls.text = "WASD   Walk\nShift   Run\nLeft Alt   Dash\nE   Interact / close chest\nI   Inventory / close\nEsc   Close inventory, or test menu\nF1   Infinite stamina\nF2   Next skin\nF3   Diagnostics\nF4   Test footprints\n\nItems: drag, or click then place\nChest quick transfer: double-click"
    tabs.add_child(controls)
    var areas := VBoxContainer.new()
    areas.name = "Test areas"
    tabs.add_child(areas)
    _button(areas, "Scene 1 · Movement & items", "movement")
    _button(areas, "Scene 2 · Systems lab", "lab")
    var note := Label.new()
    note.text = "Cooking and combat spaces are reserved.\nThose systems are not implemented yet.\n\nTravel keeps inventory and world state.\nReset restores only the current area's world."
    areas.add_child(note)
    status = Label.new()
    status.add_theme_font_size_override("font_size", 12)
    content.add_child(status)
    _button(content, "Resume · Esc", "resume")
    hide()
    get_viewport().size_changed.connect(_layout)

func _button(parent: Node, title: String, command: String) -> Button:
    var button := Button.new()
    button.text = title
    button.pressed.connect(func(): command_requested.emit(command))
    parent.add_child(button)
    return button

func set_open(value: bool) -> void:
    is_open = value
    visible = value
    cancel_reset()
    open_changed.emit(value)
    if value:
        _layout()
        infinite_button.grab_focus()

func cancel_reset() -> void:
    confirm_reset = false
    if reset_button != null:
        reset_button.text = "Reset current test area…"
        status.text = ""

func sync(player: DemoPlayer, diagnostics: bool, footprints: bool) -> void:
    infinite_button.text = "F1 · Infinite stamina: " + ("ON" if player.infinite_stamina else "OFF")
    skin_button.text = "F2 · Skin %d / %d · Next" % [player.current_skin + 1, player.get_skin_count()]
    diagnostics_button.text = "F3 · Diagnostics: " + ("ON" if diagnostics else "OFF")
    footprints_button.text = "F4 · Test footprints: " + ("ON" if footprints else "OFF")

func _layout() -> void:
    var viewport_size := get_viewport().get_visible_rect().size
    var ui_scale := minf(1.0, minf(viewport_size.x / 540.0, viewport_size.y / 560.0))
    panel.scale = Vector2.ONE * ui_scale
    panel.size = Vector2(510, 0)
    panel.position = (viewport_size - panel.size * ui_scale) * 0.5
