class_name PebblePatch
extends Area2D

var patch_size := Vector2(250, 95)
var pebble_texture: Texture2D = preload("res://assets/terrain/rocks/pebbles.png")
var settings: Dictionary = {}

func _ready() -> void:
    add_to_group("pebble_patches")
    collision_layer = 2
    collision_mask = 0
    set_meta("terrain_name", "rocks")
    set_meta("movement_multiplier", float(settings.get("movement_multiplier", 0.55)))
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = patch_size
    collision.shape = shape
    add_child(collision)
    # One continuous slow zone beneath a dense, staggered field of transparent sprites.
    var region := pebble_texture.get_image().get_used_rect()
    var width := maxf(1.0, float(settings.get("pebble_width", 26)))
    var factor := width / maxf(1.0, float(region.size.x))
    var height := float(region.size.y) * factor
    var spacing := maxf(1.0, float(settings.get("spacing", 21)))
    var jitter := maxf(0.0, float(settings.get("jitter", 2)))
    var half := patch_size * 0.5
    var rng := RandomNumberGenerator.new()
    rng.seed = int(settings.get("layout_seed", 6006)) + roundi(position.x + position.y)
    var row := 0
    var y := -half.y + height * 0.5
    while y <= half.y - height * 0.5:
        var x := -half.x + width * 0.5 + (spacing * 0.5 if row % 2 else 0.0)
        while x <= half.x - width * 0.5:
            var sprite := Sprite2D.new()
            sprite.texture = pebble_texture
            sprite.region_enabled = true
            sprite.region_rect = region
            sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
            sprite.scale = Vector2.ONE * factor
            sprite.position = Vector2(
                clampf(x + rng.randf_range(-jitter, jitter), -half.x + width * 0.5, half.x - width * 0.5),
                clampf(y + rng.randf_range(-jitter, jitter), -half.y + height * 0.5, half.y - height * 0.5))
            sprite.flip_h = rng.randf() > 0.5
            add_child(sprite)
            x += spacing
        y += spacing * 0.75
        row += 1
