class_name TestChest
extends Interactable

signal opened(inventory: ItemInventory)
const SLOT_COUNT := 32
var inventory: ItemInventory
var closed_texture: Texture2D = preload("res://assets/items/placeable_items/box.png")
var open_texture: Texture2D = preload("res://assets/items/placeable_items/box-open.png")
var display_scale := 1.0
var collision_size := Vector2(26, 14)
var sprite: Sprite2D
var is_open := false

func _ready() -> void:
    super._ready()
    interaction_label = "Open chest (%d slots)" % inventory.size()
    collision_layer = 1
    collision_mask = 1
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = collision_size
    collision.position.y = -collision_size.y * 0.5
    collision.shape = shape
    add_child(collision)
    sprite = Sprite2D.new()
    sprite.name = "ChestSprite"
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.scale = Vector2.ONE * display_scale
    sprite.position.y = -20.0 * display_scale
    add_child(sprite)
    set_open(false)

func _process(_delta: float) -> void:
    z_index = roundi(global_position.y)

func interact(_actor: Node2D) -> void:
    set_open(true)
    opened.emit(inventory)

func set_open(open: bool) -> void:
    is_open = open
    if sprite != null:
        sprite.texture = open_texture if open else closed_texture
