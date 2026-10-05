class_name FruitBush
extends HarvestablePlant

var plant_texture: Texture2D
var display_width := 40.0
var slow_settings: Dictionary = {}
var sprite: Sprite2D

func _ready() -> void:
    super._ready()
    add_to_group("fruit_plants")
    # The fruiting plant is walkable; its footprint uses the terrain layer only.
    collision_layer = 0
    collision_mask = 0
    sprite = Sprite2D.new()
    sprite.name = "PlantSprite"
    sprite.texture = plant_texture
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var region := plant_texture.get_image().get_used_rect()
    sprite.region_enabled = true
    sprite.region_rect = region
    var factor := display_width / maxf(1.0, float(region.size.x))
    sprite.scale = Vector2.ONE * factor
    sprite.position.y = -float(region.size.y) * factor * 0.5
    add_child(sprite)
    visual_node = sprite
    interaction_offset = Vector2(0, -8)
    drop_offset = Vector2(0, 8)

    var area := Area2D.new()
    area.name = "SlowFootprint"
    area.collision_layer = 2
    area.collision_mask = 0
    area.set_meta("terrain_name", "bush")
    area.set_meta("movement_multiplier", float(slow_settings.get("movement_multiplier", 0.75)))
    var shape := CircleShape2D.new()
    shape.radius = float(slow_settings.get("harvest_plant_radius", 15))
    var collision := CollisionShape2D.new()
    collision.shape = shape
    collision.position.y = -4
    area.add_child(collision)
    add_child(area)

func _process(delta: float) -> void:
    super._process(delta)
    z_index = roundi(global_position.y)
