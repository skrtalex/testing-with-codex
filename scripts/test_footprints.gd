extends Node2D

var sandbox: Node2D

func _process(_delta: float) -> void:
    queue_redraw()

func _draw() -> void:
    if sandbox == null or not sandbox.footprints:
        return
    _draw_shapes(sandbox.area_root)
    _draw_shapes(sandbox.player)
    var actor: DemoPlayer = sandbox.player
    draw_set_transform(actor.position, actor.last_facing.angle())
    var reach: float = sandbox.interaction_detector.reach
    var width: float = sandbox.interaction_detector.half_width
    draw_rect(Rect2(0, -width, reach, width * 2), Color(1, 0.85, 0.3, 0.7), false, 1.5)
    draw_set_transform(Vector2.ZERO)

func _draw_shapes(node: Node) -> void:
    if node is CollisionShape2D and node.shape != null and not node.disabled:
        draw_set_transform_matrix(global_transform.affine_inverse() * node.global_transform)
        node.shape.draw(get_canvas_item(), Color(0.25, 0.85, 1, 0.32))
    elif node is CollisionPolygon2D and not node.disabled:
        draw_set_transform_matrix(global_transform.affine_inverse() * node.global_transform)
        draw_colored_polygon(node.polygon, Color(0.25, 0.85, 1, 0.32))
    for child in node.get_children():
        _draw_shapes(child)
