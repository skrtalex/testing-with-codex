class_name SlowBush
extends Area2D

var bush_texture: Texture2D
var settings: Dictionary = {}
var sprite: Sprite2D

func _ready() -> void:
    add_to_group("slow_bushes")
    # Walkable terrain only: no solid collision layer.
    collision_layer = 2
    collision_mask = 0
    set_meta("terrain_name", "bush")
    set_meta("movement_multiplier", float(settings.get("movement_multiplier", 0.75)))
    sprite = Sprite2D.new()
    sprite.name = "BushSprite"
    sprite.texture = bush_texture
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    # Use visible pixels from the padded export without modifying the source PNG.
    var region := bush_texture.get_image().get_used_rect()
    sprite.region_enabled = true
    sprite.region_rect = region
    var display_width := maxf(1.0, float(settings.get("display_width", 34)))
    var factor := display_width / maxf(1.0, float(region.size.x))
    sprite.scale = Vector2.ONE * factor
    sprite.position.y = -float(region.size.y) * factor * 0.5
    add_child(sprite)

    var footprint := Vector2(float(settings.get("slow_half_width", 17)), float(settings.get("slow_half_height", 10)))
    var points := PackedVector2Array()
    for i in range(20):
        var angle := TAU * float(i) / 20.0
        points.append(Vector2(cos(angle) * footprint.x, sin(angle) * footprint.y))
    var shape := ConvexPolygonShape2D.new()
    shape.points = points
    var collision := CollisionShape2D.new()
    collision.name = "SlowFootprint"
    collision.shape = shape
    collision.position.y = float(settings.get("slow_offset_y", -4))
    add_child(collision)

func _process(_delta: float) -> void:
    z_index = roundi(global_position.y)
