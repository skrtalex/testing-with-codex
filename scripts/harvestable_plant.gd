class_name HarvestablePlant
extends Interactable

signal drop_requested(item_id: String, quantity: int, local_position: Vector2)

var drop_item_id := ""
var settings: Dictionary = {}
var cooldown_left := 0.0
var shake: Tween
var visual_node: Node2D
var drop_offset := Vector2(0, 31)

func can_interact(_actor: Node2D) -> bool:
    return cooldown_left <= 0.0 and not drop_item_id.is_empty()

func _process(delta: float) -> void:
    cooldown_left = maxf(0.0, cooldown_left - delta)

func interact(actor: Node2D) -> void:
    if not can_interact(actor):
        return
    var duration := maxf(0.05, float(settings.get("shake_seconds", 0.32)))
    cooldown_left = maxf(duration, float(settings.get("cooldown_seconds", 3.0)))
    var canopy := visual_node
    if canopy == null:
        _drop_fruit()
        return
    var origin_x := canopy.position.x
    var distance := float(settings.get("shake_pixels", 4.0))
    shake = create_tween()
    for x in [distance, -distance, distance * 0.5, 0.0]:
        shake.tween_property(canopy, "position:x", origin_x + x, duration / 4.0)
    shake.tween_callback(_drop_fruit)

func _drop_fruit() -> void:
    var minimum := maxi(1, int(settings.get("min_drop", 1)))
    var maximum := maxi(minimum, int(settings.get("max_drop", 3)))
    var amount := randi_range(minimum, maximum)
    var radius := maxf(1.0, float(settings.get("scatter_radius", 22.0)))
    var phase := randf() * TAU
    for i in range(amount):
        var angle := phase + TAU * float(i) / float(amount)
        var scatter := Vector2(cos(angle), sin(angle)) * randf_range(radius * 0.55, radius)
        drop_requested.emit(drop_item_id, 1, position + drop_offset + scatter)
