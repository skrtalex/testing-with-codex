class_name ItemInventory
extends RefCounted

signal changed

var catalog: ItemCatalog
var _slots: Array[Dictionary] = []

func _init(item_catalog: ItemCatalog, capacity: int) -> void:
    catalog = item_catalog
    for i in range(maxi(1, capacity)):
        _slots.append({})

func size() -> int:
    return _slots.size()

func slot(index: int) -> Dictionary:
    return _slots[index].duplicate() if _valid(index) else {}

func _valid(index: int) -> bool:
    return index >= 0 and index < size()

func available_capacity(id: String) -> int:
    var limit := catalog.stack_limit(id)
    var capacity := 0
    for stack in _slots:
        if stack.is_empty():
            capacity += limit
        elif stack["item_id"] == id:
            capacity += limit - int(stack["quantity"])
    return capacity

# Returns the amount accepted. Callers retain any remainder.
func add_items(id: String, quantity: int) -> int:
    if quantity <= 0 or not catalog.has_item(id):
        return 0
    var left := quantity
    var limit := catalog.stack_limit(id)
    for stack in _slots:
        if not stack.is_empty() and stack["item_id"] == id:
            var amount := mini(left, limit - int(stack["quantity"]))
            stack["quantity"] += amount
            left -= amount
    for i in range(size()):
        if left <= 0:
            break
        if _slots[i].is_empty():
            var amount := mini(left, limit)
            _slots[i] = {"item_id": id, "quantity": amount}
            left -= amount
    if left != quantity:
        changed.emit()
    return quantity - left

func remove_items(index: int, quantity: int) -> int:
    if not _valid(index) or _slots[index].is_empty() or quantity <= 0:
        return 0
    var amount := mini(quantity, int(_slots[index]["quantity"]))
    _slots[index]["quantity"] -= amount
    if int(_slots[index]["quantity"]) == 0:
        _slots[index] = {}
    changed.emit()
    return amount

# Merges matching stacks, moves to empty slots, or swaps differing stacks.
func move_stack(source: int, destination: int) -> bool:
    if not _valid(source) or not _valid(destination) or source == destination or _slots[source].is_empty():
        return false
    var a := _slots[source]
    var b := _slots[destination]
    if not b.is_empty() and a["item_id"] == b["item_id"]:
        var amount := mini(int(a["quantity"]), catalog.stack_limit(a["item_id"]) - int(b["quantity"]))
        if amount == 0:
            return false
        b["quantity"] += amount
        a["quantity"] -= amount
        if int(a["quantity"]) == 0:
            _slots[source] = {}
    else:
        _slots[source] = b
        _slots[destination] = a
    changed.emit()
    return true

func transfer_stack(index: int, destination: ItemInventory) -> int:
    if destination == self or not _valid(index) or _slots[index].is_empty():
        return 0
    var stack := slot(index)
    var accepted := destination.add_items(stack["item_id"], int(stack["quantity"]))
    if accepted > 0:
        remove_items(index, accepted)
    return accepted
