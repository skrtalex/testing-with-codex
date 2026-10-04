class_name InventoryUI
extends CanvasLayer

signal open_changed(open: bool)

var player_inventory: ItemInventory
var chest_inventory: ItemInventory
var panel: PanelContainer
var content: VBoxContainer
var status: Label
var selected := -1
var selected_inventory: ItemInventory
var slot_buttons: Array[InventorySlot] = []
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
    selected_inventory = null
    is_open = true
    _build_content()
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
    selected_inventory = null
    _disconnect_chest()
    panel.hide()
    open_changed.emit(false)

func toggle_player() -> void:
    if is_open:
        close()
        return
    selected = -1
    selected_inventory = null
    is_open = true
    _build_content()
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

func _build_content() -> void:
    slot_buttons.clear()
    for child in content.get_children():
        content.remove_child(child)
        child.queue_free()
    var title := Label.new()
    title.text = "Chest transfer" if chest_inventory != null else "Player inventory"
    content.add_child(title)
    var hint := Label.new()
    hint.text = "Drag or click then place. Double-click transfers. I / E / Esc closes." if chest_inventory != null else "Drag or click then place to move, merge or swap. I / Esc closes."
    hint.add_theme_font_size_override("font_size", 13)
    content.add_child(hint)
    _add_grid("Player (%d slots)" % player_inventory.size(), player_inventory)
    if chest_inventory != null:
        _add_grid("Chest (%d slots)" % chest_inventory.size(), chest_inventory)
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
    if inventory.size() > 32:
        # Keep large chests readable rather than shrinking every slot to fit.
        var scroll := ScrollContainer.new()
        scroll.name = "LargeChestScroll"
        scroll.custom_minimum_size = Vector2(540, 200)
        scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
        content.add_child(scroll)
        scroll.add_child(grid)
    else:
        content.add_child(grid)
    for i in range(inventory.size()):
        var button := InventorySlot.new()
        button.inventory = inventory
        button.index = i
        button.inventory_ui = self
        slot_buttons.append(button)
        button.name = "Slot%d" % i
        button.custom_minimum_size = Vector2(62, 45)
        button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        button.expand_icon = true
        button.add_theme_constant_override("icon_max_width", 28)
        button.clicked.connect(_slot_clicked)
        button.double_clicked.connect(_slot_double_clicked)
        grid.add_child(button)

func _refresh() -> void:
    if not is_open:
        return
    # Preserve slot controls across updates so drags, double-clicks and focus survive.
    for button in slot_buttons:
        var stack := button.inventory.slot(button.index)
        button.icon = null
        button.text = "-"
        button.tooltip_text = "Empty slot"
        if not stack.is_empty():
            button.icon = button.inventory.catalog.icon(stack["item_id"])
            button.text = str(stack["quantity"])
            button.tooltip_text = "%s (%d / %d)" % [button.inventory.catalog.display_name(stack["item_id"]), stack["quantity"], button.inventory.catalog.stack_limit(stack["item_id"])]
        button.modulate = Color("ffe08a") if selected_inventory == button.inventory and selected == button.index else Color.WHITE

func clear_selection() -> void:
    selected = -1
    selected_inventory = null
    _refresh()

func _slot_clicked(source: ItemInventory, index: int) -> void:
    if not is_open:
        return
    if selected_inventory == null:
        if not source.slot(index).is_empty():
            selected = index
            selected_inventory = source
            _refresh()
        return
    var from := selected
    var origin := selected_inventory
    clear_selection()
    if origin == source and from == index:
        return
    if not origin.move_to_slot(from, source, index):
        status.text = "Cannot move here: stack retained."
    else:
        status.text = "Stack moved."

func _slot_double_clicked(source: ItemInventory, index: int) -> void:
    clear_selection()
    if not is_open or chest_inventory == null:
        return
    var quantity := int(source.slot(index).get("quantity", 0))
    var destination := chest_inventory if source == player_inventory else player_inventory
    var moved := source.transfer_stack(index, destination)
    status.text = "Transferred %d; %d remain." % [moved, quantity - moved] if moved < quantity else "Stack transferred."

func can_drop_stack(data: Variant, destination: ItemInventory, index: int) -> bool:
    if not is_open or not data is Dictionary or data.get("ui") != self:
        return false
    var source = data.get("inventory")
    if source == null or source not in [player_inventory, chest_inventory] or destination not in [player_inventory, chest_inventory]:
        return false
    var from := int(data.get("index", -1))
    if from < 0 or from >= source.size() or index < 0 or index >= destination.size():
        return false
    var stack: Dictionary = source.slot(from)
    if stack.is_empty() or stack != data.get("stack") or (source == destination and from == index):
        return false
    var target := destination.slot(index)
    if not target.is_empty() and stack["item_id"] == target["item_id"]:
        return int(target["quantity"]) < destination.catalog.stack_limit(stack["item_id"])
    return true

func drop_stack(data: Variant, destination: ItemInventory, index: int) -> void:
    if not can_drop_stack(data, destination, index):
        return
    var source: ItemInventory = data["inventory"]
    clear_selection()
    source.move_to_slot(int(data["index"]), destination, index)
    status.text = "Stack placed; any merge remainder stays in its original slot."

func _layout() -> void:
    if not is_instance_valid(panel):
        return
    panel.reset_size()
    var viewport_size := get_viewport().get_visible_rect().size
    var desired := panel.get_combined_minimum_size() + Vector2(20, 10)
    var ui_scale := minf(1.0, minf((viewport_size.x - 24) / desired.x, (viewport_size.y - 24) / desired.y))
    panel.scale = Vector2.ONE * maxf(0.2, ui_scale)
    panel.position = (viewport_size - panel.size * panel.scale) * 0.5
