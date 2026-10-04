class_name InventoryUI
extends CanvasLayer

signal open_changed(open: bool)

var player_inventory: ItemInventory
var chest_inventory: ItemInventory
var panel: PanelContainer
var content: VBoxContainer
var status: Label
var selected := -1
var is_open := false
var prompt: Label

func _ready() -> void:
    layer = 10
    panel = PanelContainer.new()
    panel.name = "InventoryPanel"
    add_child(panel)
    content = VBoxContainer.new()
    content.add_theme_constant_override("separation", 8)
    panel.add_child(content)
    panel.hide()
    prompt = Label.new()
    prompt.position = Vector2(18, 158)
    prompt.add_theme_color_override("font_color", Color("182418"))
    add_child(prompt)
    get_viewport().size_changed.connect(_layout)

func bind(inventory: ItemInventory) -> void:
    player_inventory = inventory
    player_inventory.changed.connect(_refresh)

func open_chest(inventory: ItemInventory) -> void:
    _disconnect_chest()
    chest_inventory = inventory
    chest_inventory.changed.connect(_refresh)
    selected = -1
    is_open = true
    _refresh()
    panel.show()
    open_changed.emit(true)

func _disconnect_chest() -> void:
    if chest_inventory != null and chest_inventory.changed.is_connected(_refresh):
        chest_inventory.changed.disconnect(_refresh)
    chest_inventory = null

func close() -> void:
    is_open = false
    selected = -1
    _disconnect_chest()
    panel.hide()
    open_changed.emit(false)

func toggle_player() -> void:
    if is_open:
        close()
        return
    selected = -1
    is_open = true
    _refresh()
    panel.show()
    open_changed.emit(true)

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_I:
            toggle_player()
            get_viewport().set_input_as_handled()
        elif is_open and event.keycode in [KEY_ESCAPE, KEY_E]:
            close()
            get_viewport().set_input_as_handled()

func _refresh() -> void:
    if not is_open:
        return
    for child in content.get_children():
        content.remove_child(child)
        child.queue_free()
    var title := Label.new()
    title.text = "Chest transfer" if chest_inventory != null else "Player inventory"
    content.add_child(title)
    var hint := Label.new()
    hint.text = "Click a stack to transfer it. I / E / Esc closes." if chest_inventory != null else "Click a stack, then a slot to move or merge. I / Esc closes."
    hint.add_theme_font_size_override("font_size", 13)
    content.add_child(hint)
    _add_grid("Player (%d slots)" % player_inventory.size(), player_inventory)
    if chest_inventory != null:
        _add_grid("Chest (32 slots)", chest_inventory)
    status = Label.new()
    status.text = "Items remain in their original inventory when the destination is full."
    status.add_theme_font_size_override("font_size", 12)
    content.add_child(status)
    var close_button := Button.new()
    close_button.text = "Close"
    close_button.pressed.connect(close)
    content.add_child(close_button)
    _layout.call_deferred()

func _add_grid(title_text: String, inventory: ItemInventory) -> void:
    var title := Label.new()
    title.text = title_text
    content.add_child(title)
    var grid := GridContainer.new()
    grid.columns = 8
    content.add_child(grid)
    for i in range(inventory.size()):
        var button := Button.new()
        button.name = "Slot%d" % i
        button.custom_minimum_size = Vector2(62, 45)
        button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        button.expand_icon = true
        button.add_theme_constant_override("icon_max_width", 28)
        var stack := inventory.slot(i)
        if stack.is_empty():
            button.text = "-"
            button.tooltip_text = "Empty slot"
        else:
            button.icon = inventory.catalog.icon(stack["item_id"])
            button.text = str(stack["quantity"])
            button.tooltip_text = "%s (%d / %d)" % [inventory.catalog.display_name(stack["item_id"]), stack["quantity"], inventory.catalog.stack_limit(stack["item_id"])]
        if chest_inventory == null and selected == i:
            button.modulate = Color("ffe08a")
        button.pressed.connect(_slot_clicked.bind(inventory, i))
        grid.add_child(button)

func _slot_clicked(source: ItemInventory, index: int) -> void:
    if chest_inventory != null:
        var destination := chest_inventory if source == player_inventory else player_inventory
        var moved := source.transfer_stack(index, destination)
        if moved == 0 and not source.slot(index).is_empty():
            status.text = "Destination full: stack retained."
    elif selected < 0:
        if not source.slot(index).is_empty():
            selected = index
            _refresh()
    else:
        var from := selected
        selected = -1
        source.move_stack(from, index)
        _refresh()

func _layout() -> void:
    if not is_instance_valid(panel):
        return
    panel.reset_size()
    var viewport_size := get_viewport().get_visible_rect().size
    var desired := panel.get_combined_minimum_size() + Vector2(20, 10)
    var ui_scale := minf(1.0, minf((viewport_size.x - 24) / desired.x, (viewport_size.y - 24) / desired.y))
    panel.scale = Vector2.ONE * maxf(0.2, ui_scale)
    panel.position = (viewport_size - panel.size * panel.scale) * 0.5
