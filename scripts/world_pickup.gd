class_name WorldPickup
extends Node2D

var item_id := ""
var quantity := 1
var catalog: ItemCatalog
var inventory: ItemInventory
var actor: DemoPlayer
var pickup_radius := 19.0
var grace_left := 0.7
var sprite: Sprite2D

func _ready() -> void:
    sprite = Sprite2D.new()
    sprite.texture = catalog.icon(item_id)
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.scale = Vector2.ONE * 0.75
    sprite.position.y = -7
    add_child(sprite)
    # Use the same screen-space Y convention as the moving player.
    z_index = roundi(global_position.y)

func try_pickup() -> int:
    var accepted := inventory.add_items(item_id, quantity)
    quantity -= accepted
    if quantity == 0:
        queue_free()
    return accepted

func _physics_process(delta: float) -> void:
    z_index = roundi(global_position.y)
    grace_left = maxf(0.0, grace_left - delta)
    if grace_left > 0.0 or actor.inventory_open:
        return
    if global_position.distance_to(actor.global_position) <= pickup_radius * absf(global_scale.x):
        try_pickup()

func _draw() -> void:
    draw_ellipse_shadow()

func draw_ellipse_shadow() -> void:
    draw_circle(Vector2.ZERO, 4.0, Color(0, 0, 0, 0.16))
