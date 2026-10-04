class_name InventorySlot
extends Button

signal clicked(inventory: ItemInventory, index: int)
signal double_clicked(inventory: ItemInventory, index: int)

var inventory: ItemInventory
var index := -1
var inventory_ui: InventoryUI
var _dragging := false
var _skip_release := false

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed and event.double_click:
            _skip_release = true
            double_clicked.emit(inventory, index)
            accept_event()
        elif not event.pressed:
            if not _dragging and not _skip_release:
                clicked.emit(inventory, index)
            _skip_release = false
            accept_event()

func _get_drag_data(_position: Vector2) -> Variant:
    var stack := inventory.slot(index)
    if stack.is_empty() or not inventory_ui.is_open:
        return null
    _dragging = true
    _skip_release = true
    inventory_ui.clear_selection()
    var preview := HBoxContainer.new()
    preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var image := TextureRect.new()
    image.texture = inventory.catalog.icon(stack["item_id"])
    image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    image.custom_minimum_size = Vector2(32, 32)
    image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    image.mouse_filter = Control.MOUSE_FILTER_IGNORE
    preview.add_child(image)
    var count := Label.new()
    count.text = str(stack["quantity"])
    count.mouse_filter = Control.MOUSE_FILTER_IGNORE
    preview.add_child(count)
    set_drag_preview(preview)
    return {"ui": inventory_ui, "inventory": inventory, "index": index, "stack": stack}

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
    return inventory_ui.can_drop_stack(data, inventory, index)

func _drop_data(_position: Vector2, data: Variant) -> void:
    inventory_ui.drop_stack(data, inventory, index)

func _notification(what: int) -> void:
    if what == NOTIFICATION_DRAG_END:
        _dragging = false
        # Clear after the release event so ending a drag never becomes a click.
        set_deferred("_skip_release", false)
