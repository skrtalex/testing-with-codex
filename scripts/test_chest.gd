class_name TestChest
extends Interactable

signal opened(inventory: ItemInventory)
const SLOT_COUNT := 32
var inventory: ItemInventory

func _ready() -> void:
    super._ready()
    interaction_label = "Open chest"
    collision_layer = 1
    collision_mask = 1
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = Vector2(32, 20)
    collision.position.y = -4
    collision.shape = shape
    add_child(collision)
    queue_redraw()

func _process(_delta: float) -> void:
    z_index = roundi(global_position.y)

func interact(_actor: Node2D) -> void:
    opened.emit(inventory)

func _draw() -> void:
    draw_rect(Rect2(-18, -24, 36, 24), Color("74452b"))
    draw_rect(Rect2(-18, -24, 36, 9), Color("b78044"))
    draw_rect(Rect2(-18, -24, 36, 24), Color("3d2b20"), false, 2)
    draw_rect(Rect2(-4, -16, 8, 7), Color("ebc65e"))
