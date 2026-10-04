extends Node2D

const MAP_SIZE := Vector2(960.0, 600.0)
const BUSH_TEXTURE := preload("res://assets/terrain/bush_tile.png")
const ROCK_TEXTURE := preload("res://assets/terrain/rock_tile.png")

const HUD_MARGIN := 18.0
const TOP_LEFT_SIZE := Vector2(314.0, 182.0)
const BOTTOM_SIZE := Vector2(760.0, 36.0)
const VERSION_SIZE := Vector2(240.0, 26.0)

var config: Dictionary = {}
var terrain_config: Dictionary = {}

var player: DemoPlayer
var top_left_hud: Control
var bottom_controls: Control
var version_text: Label
var stamina_bar: ProgressBar
var stamina_text: Label
var terrain_text: Label
var movement_text: Label
var debug_text: Label
var skin_text: Label
var controls_text: Label

func _ready() -> void:
    print("Main: initializing movement sandbox")
    if not _find_scene_nodes():
        push_error("Main: required scene nodes are missing; initialization stopped.")
        return

    config = GameConfig.load_data()
    terrain_config = config.get("terrain", {})

    _build_test_area()
    _connect_player_signals()

    controls_text.text = "WASD Walk   |   Shift Run   |   Left Alt Dash   |   F1 Infinite stamina   |   F2 Change skin"
    version_text.text = "Movement Sandbox  v%s" % str(config.get("balance_version", "0.0.0.5"))

    _on_stamina_changed(player.stamina, player.max_stamina)
    _on_terrain_changed(player.current_terrain, player.terrain_multiplier)
    _on_infinite_stamina_changed(player.infinite_stamina)
    _on_skin_changed(player.current_skin, player.get_skin_count())

    if not get_viewport().size_changed.is_connected(_update_layout):
        get_viewport().size_changed.connect(_update_layout)
    print("Main: player signals and viewport layout callback connected")
    _update_layout()
    queue_redraw()

func _find_scene_nodes() -> bool:
    player = get_node_or_null("Player") as DemoPlayer
    top_left_hud = get_node_or_null("HUD/Root/TopLeft") as Control
    bottom_controls = get_node_or_null("HUD/Root/BottomControls") as Control
    version_text = get_node_or_null("HUD/Root/VersionText") as Label
    stamina_bar = get_node_or_null("HUD/Root/TopLeft/StaminaBar") as ProgressBar
    stamina_text = get_node_or_null("HUD/Root/TopLeft/StaminaText") as Label
    terrain_text = get_node_or_null("HUD/Root/TopLeft/TerrainText") as Label
    movement_text = get_node_or_null("HUD/Root/TopLeft/MovementText") as Label
    debug_text = get_node_or_null("HUD/Root/TopLeft/DebugText") as Label
    skin_text = get_node_or_null("HUD/Root/TopLeft/SkinText") as Label
    controls_text = get_node_or_null("HUD/Root/BottomControls/ControlsText") as Label

    var required_nodes: Dictionary = {
        "Player": player,
        "HUD/Root/TopLeft": top_left_hud,
        "HUD/Root/BottomControls": bottom_controls,
        "HUD/Root/VersionText": version_text,
        "HUD/Root/TopLeft/StaminaBar": stamina_bar,
        "HUD/Root/TopLeft/StaminaText": stamina_text,
        "HUD/Root/TopLeft/TerrainText": terrain_text,
        "HUD/Root/TopLeft/MovementText": movement_text,
        "HUD/Root/TopLeft/DebugText": debug_text,
        "HUD/Root/TopLeft/SkinText": skin_text,
        "HUD/Root/BottomControls/ControlsText": controls_text,
    }
    var all_found := true
    for node_path in required_nodes:
        if required_nodes[node_path] == null:
            push_error("Main: missing required node '%s'." % node_path)
            all_found = false
    if all_found:
        print("Main: all required scene nodes found")
    return all_found

func _connect_player_signals() -> void:
    if not player.stamina_changed.is_connected(_on_stamina_changed):
        player.stamina_changed.connect(_on_stamina_changed)
    if not player.terrain_changed.is_connected(_on_terrain_changed):
        player.terrain_changed.connect(_on_terrain_changed)
    if not player.infinite_stamina_changed.is_connected(_on_infinite_stamina_changed):
        player.infinite_stamina_changed.connect(_on_infinite_stamina_changed)
    if not player.movement_state_changed.is_connected(_on_movement_state_changed):
        player.movement_state_changed.connect(_on_movement_state_changed)
    if not player.skin_changed.is_connected(_on_skin_changed):
        player.skin_changed.connect(_on_skin_changed)

func _update_layout() -> void:
    var viewport_size := get_viewport_rect().size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return

    var world_scale := minf(viewport_size.x / MAP_SIZE.x, viewport_size.y / MAP_SIZE.y)
    world_scale = maxf(world_scale, 0.25)
    scale = Vector2.ONE * world_scale
    position = (viewport_size - (MAP_SIZE * world_scale)) * 0.5

    var ui_scale := clampf(world_scale, 0.85, 1.55)
    top_left_hud.scale = Vector2.ONE * ui_scale
    top_left_hud.position = Vector2(HUD_MARGIN, HUD_MARGIN)

    bottom_controls.scale = Vector2.ONE * ui_scale
    bottom_controls.position = Vector2(
        (viewport_size.x - (BOTTOM_SIZE.x * ui_scale)) * 0.5,
        viewport_size.y - HUD_MARGIN - (BOTTOM_SIZE.y * ui_scale)
    )

    version_text.scale = Vector2.ONE * ui_scale
    version_text.position = Vector2(
        viewport_size.x - HUD_MARGIN - (VERSION_SIZE.x * ui_scale),
        HUD_MARGIN
    )

func _build_test_area() -> void:
    # Outer boundary walls.
    _add_solid_rect(Rect2(0, 0, 960, 18), "Wall")
    _add_solid_rect(Rect2(0, 582, 960, 18), "Wall")
    _add_solid_rect(Rect2(0, 0, 18, 600), "Wall")
    _add_solid_rect(Rect2(942, 0, 18, 600), "Wall")

    # Top-left tree collision pocket.
    for tree_pos in [
        Vector2(110, 112), Vector2(160, 112), Vector2(210, 112),
        Vector2(110, 162), Vector2(210, 162),
        Vector2(110, 212), Vector2(160, 212), Vector2(210, 212)
    ]:
        _add_tree(tree_pos)

    # Top-middle wall / corridor collision test with a chunkier 3/4 facade feel.
    _add_solid_rect(Rect2(330, 90, 230, 24), "Wall")
    _add_solid_rect(Rect2(330, 90, 24, 120), "Wall")
    _add_solid_rect(Rect2(536, 90, 24, 120), "Wall")
    _add_solid_rect(Rect2(330, 186, 85, 24), "Wall")
    _add_solid_rect(Rect2(475, 186, 85, 24), "Wall")

    # Slow terrain strips.
    _add_terrain_rect(Rect2(90, 275, 250, 95), "bush")
    _add_terrain_rect(Rect2(620, 275, 250, 95), "rocks")

    # Bottom obstacle course: mix of solids and slow terrain.
    _add_terrain_rect(Rect2(80, 445, 135, 60), "bush")
    _add_terrain_rect(Rect2(420, 475, 150, 55), "rocks")
    _add_terrain_rect(Rect2(720, 430, 140, 60), "bush")

    _add_tree(Vector2(275, 472))
    _add_tree(Vector2(315, 520))
    _add_tree(Vector2(650, 515))

    _add_solid_rect(Rect2(355, 425, 120, 20), "Wall")
    _add_solid_rect(Rect2(585, 420, 22, 110), "Wall")
    _add_solid_rect(Rect2(810, 520, 95, 20), "Wall")

    # A few explicit 3/4 decorative objects to sell the new angle.
    _add_boulder(Vector2(720, 180), 18.0)
    _add_bush(Vector2(780, 470), Vector2(26.0, 18.0))
    _add_facade(Vector2(780, 120), Vector2(110.0, 62.0))

func _set_y_sort(node: Node2D, sort_y: float) -> void:
    node.z_index = int(round(sort_y))

func _add_solid_rect(rect: Rect2, label_name: String) -> void:
    var body := StaticBody2D.new()
    body.name = label_name
    body.collision_layer = 1
    body.collision_mask = 1
    body.position = rect.get_center()
    _set_y_sort(body, rect.end.y)

    var shape_node := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    shape_node.shape = shape
    body.add_child(shape_node)

    # 3/4-ish wall: front face + slanted top lip.
    var front := Polygon2D.new()
    front.polygon = PackedVector2Array([
        Vector2(-rect.size.x * 0.5, -rect.size.y * 0.5),
        Vector2(rect.size.x * 0.5, -rect.size.y * 0.5),
        Vector2(rect.size.x * 0.5, rect.size.y * 0.5),
        Vector2(-rect.size.x * 0.5, rect.size.y * 0.5)
    ])
    front.color = Color("8b6547")
    body.add_child(front)

    var top_lip_depth := minf(10.0, minf(rect.size.x, rect.size.y) * 0.45)
    var inset := minf(6.0, minf(rect.size.x, rect.size.y) * 0.18)
    var top := Polygon2D.new()
    top.polygon = PackedVector2Array([
        Vector2(-rect.size.x * 0.5, -rect.size.y * 0.5),
        Vector2(rect.size.x * 0.5, -rect.size.y * 0.5),
        Vector2(rect.size.x * 0.5 - inset, -rect.size.y * 0.5 - top_lip_depth),
        Vector2(-rect.size.x * 0.5 + inset, -rect.size.y * 0.5 - top_lip_depth)
    ])
    top.color = Color("a88463")
    body.add_child(top)

    var shadow := Polygon2D.new()
    shadow.polygon = _ellipse_polygon(rect.size.x * 0.48, maxf(5.0, rect.size.y * 0.33), 18)
    shadow.position = Vector2(4.0, rect.size.y * 0.46 + 5.0)
    shadow.color = Color(0.0, 0.0, 0.0, 0.18)
    shadow.z_index = -3
    body.add_child(shadow)

    add_child(body)

func _add_tree(tree_pos: Vector2) -> void:
    var body := StaticBody2D.new()
    body.name = "Tree"
    body.collision_layer = 1
    body.collision_mask = 1
    body.position = tree_pos
    _set_y_sort(body, tree_pos.y + 26.0)

    var shadow := Polygon2D.new()
    shadow.polygon = _ellipse_polygon(28.0, 13.0, 24)
    shadow.position = Vector2(7.0, 28.0)
    shadow.color = Color(0.0, 0.0, 0.0, 0.16)
    shadow.z_index = -4
    body.add_child(shadow)

    var shape_node := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = Vector2(14.0, 18.0)
    shape_node.position = Vector2(0.0, 13.0)
    shape_node.shape = shape
    body.add_child(shape_node)

    var trunk_back := Polygon2D.new()
    trunk_back.polygon = PackedVector2Array([
        Vector2(-10.0, -8.0), Vector2(10.0, -8.0), Vector2(8.0, 22.0), Vector2(-8.0, 22.0)
    ])
    trunk_back.color = Color("6d462d")
    body.add_child(trunk_back)

    var trunk_front := Polygon2D.new()
    trunk_front.polygon = PackedVector2Array([
        Vector2(-9.0, -6.0), Vector2(9.0, -6.0), Vector2(7.0, 24.0), Vector2(-7.0, 24.0)
    ])
    trunk_front.color = Color("8c5b36")
    body.add_child(trunk_front)

    var root_left := Polygon2D.new()
    root_left.polygon = PackedVector2Array([
        Vector2(-7.0, 20.0), Vector2(-15.0, 31.0), Vector2(-5.0, 28.0)
    ])
    root_left.color = Color("7a5032")
    body.add_child(root_left)

    var root_right := Polygon2D.new()
    root_right.polygon = PackedVector2Array([
        Vector2(7.0, 20.0), Vector2(15.0, 31.0), Vector2(5.0, 28.0)
    ])
    root_right.color = Color("7a5032")
    body.add_child(root_right)

    var canopy := Node2D.new()
    canopy.name = "Canopy"
    canopy.z_index = 80
    body.add_child(canopy)
    _add_canopy_blob(canopy, Vector2(-18.0, -6.0), 19.0, Color("2f6f3b"))
    _add_canopy_blob(canopy, Vector2(18.0, -6.0), 19.0, Color("2c6937"))
    _add_canopy_blob(canopy, Vector2(0.0, -28.0), 22.0, Color("377c43"))
    _add_canopy_blob(canopy, Vector2(-5.0, -20.0), 18.0, Color("3d8a4c"))
    _add_canopy_blob(canopy, Vector2(8.0, -18.0), 17.0, Color("4b9a59"))
    _add_canopy_blob(canopy, Vector2(0.0, -8.0), 20.0, Color("3b8247"))

    add_child(body)

func _add_canopy_blob(parent: Node, offset: Vector2, radius: float, color: Color) -> void:
    var blob := Polygon2D.new()
    blob.polygon = _circle_polygon(radius, 16)
    blob.position = offset
    blob.color = color
    parent.add_child(blob)

func _add_boulder(pos: Vector2, radius: float) -> void:
    var node := Node2D.new()
    node.position = pos
    _set_y_sort(node, pos.y)

    var shadow := Polygon2D.new()
    shadow.polygon = _ellipse_polygon(radius * 1.0, radius * 0.42, 18)
    shadow.position = Vector2(4.0, radius * 0.8)
    shadow.color = Color(0, 0, 0, 0.18)
    shadow.z_index = -2
    node.add_child(shadow)

    var rock := Polygon2D.new()
    rock.polygon = PackedVector2Array([
        Vector2(-radius * 0.9, radius * 0.1),
        Vector2(-radius * 0.55, -radius * 0.7),
        Vector2(radius * 0.25, -radius * 0.9),
        Vector2(radius * 0.85, -radius * 0.2),
        Vector2(radius * 0.75, radius * 0.65),
        Vector2(-radius * 0.25, radius * 0.85)
    ])
    rock.color = Color("8f8b87")
    node.add_child(rock)

    var highlight := Polygon2D.new()
    highlight.polygon = PackedVector2Array([
        Vector2(-radius * 0.4, -radius * 0.35),
        Vector2(radius * 0.1, -radius * 0.55),
        Vector2(radius * 0.2, -radius * 0.1),
        Vector2(-radius * 0.2, 0.0)
    ])
    highlight.color = Color("b6b3af")
    node.add_child(highlight)

    add_child(node)

func _add_bush(pos: Vector2, size: Vector2) -> void:
    var node := Node2D.new()
    node.position = pos
    _set_y_sort(node, pos.y)

    var shadow := Polygon2D.new()
    shadow.polygon = _ellipse_polygon(size.x * 0.85, size.y * 0.38, 20)
    shadow.position = Vector2(4.0, size.y * 0.75)
    shadow.color = Color(0, 0, 0, 0.14)
    shadow.z_index = -2
    node.add_child(shadow)

    _add_canopy_blob(node, Vector2(-size.x * 0.32, 0.0), size.y * 0.9, Color("387f45"))
    _add_canopy_blob(node, Vector2(size.x * 0.28, -2.0), size.y * 0.88, Color("2e6f3d"))
    _add_canopy_blob(node, Vector2(0.0, -size.y * 0.35), size.y * 0.95, Color("4d9d5f"))

    add_child(node)

func _add_facade(pos: Vector2, size: Vector2) -> void:
    var node := Node2D.new()
    node.position = pos
    _set_y_sort(node, pos.y + size.y)

    var shadow := Polygon2D.new()
    shadow.polygon = _ellipse_polygon(size.x * 0.48, 10.0, 20)
    shadow.position = Vector2(8.0, size.y * 0.55 + 12.0)
    shadow.color = Color(0, 0, 0, 0.16)
    shadow.z_index = -2
    node.add_child(shadow)

    var wall := Polygon2D.new()
    wall.polygon = PackedVector2Array([
        Vector2(-size.x * 0.5, -size.y * 0.5), Vector2(size.x * 0.5, -size.y * 0.5),
        Vector2(size.x * 0.5, size.y * 0.5), Vector2(-size.x * 0.5, size.y * 0.5)
    ])
    wall.color = Color("cab9a1")
    node.add_child(wall)

    var roof := Polygon2D.new()
    roof.polygon = PackedVector2Array([
        Vector2(-size.x * 0.55, -size.y * 0.5), Vector2(size.x * 0.55, -size.y * 0.5),
        Vector2(size.x * 0.43, -size.y * 0.72), Vector2(-size.x * 0.43, -size.y * 0.72)
    ])
    roof.color = Color("b86d43")
    node.add_child(roof)

    var door := Polygon2D.new()
    var door_w := size.x * 0.24
    var door_h := size.y * 0.58
    door.polygon = PackedVector2Array([
        Vector2(-door_w * 0.5, size.y * 0.5), Vector2(door_w * 0.5, size.y * 0.5),
        Vector2(door_w * 0.5, size.y * 0.5 - door_h), Vector2(-door_w * 0.5, size.y * 0.5 - door_h)
    ])
    door.color = Color("7b4d31")
    node.add_child(door)

    add_child(node)

func _add_terrain_rect(rect: Rect2, terrain_name: String) -> void:
    var area := Area2D.new()
    area.name = "%sTerrain" % terrain_name.capitalize()
    area.z_index = -5
    area.collision_layer = 2
    area.collision_mask = 0
    area.position = rect.get_center()

    var terrain_data: Dictionary = terrain_config.get(terrain_name, {})
    var multiplier := float(terrain_data.get("movement_multiplier", 1.0))
    area.set_meta("terrain_name", terrain_name)
    area.set_meta("movement_multiplier", multiplier)

    var shape_node := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    shape_node.shape = shape
    area.add_child(shape_node)

    var polygon := PackedVector2Array([
        Vector2(-rect.size.x * 0.5, -rect.size.y * 0.5),
        Vector2(rect.size.x * 0.5, -rect.size.y * 0.5),
        Vector2(rect.size.x * 0.5, rect.size.y * 0.5),
        Vector2(-rect.size.x * 0.5, rect.size.y * 0.5)
    ])

    var visual := Polygon2D.new()
    visual.polygon = polygon
    visual.texture = _get_terrain_texture(terrain_name)
    visual.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
    visual.uv = PackedVector2Array([
        Vector2(0.0, 0.0),
        Vector2(rect.size.x, 0.0),
        Vector2(rect.size.x, rect.size.y),
        Vector2(0.0, rect.size.y)
    ])
    visual.color = Color(1, 1, 1, 0.98)
    area.add_child(visual)

    add_child(area)

func _get_terrain_texture(terrain_name: String) -> Texture2D:
    match terrain_name:
        "bush":
            return BUSH_TEXTURE
        "rocks":
            return ROCK_TEXTURE
        _:
            return BUSH_TEXTURE

func _circle_polygon(radius: float, points: int) -> PackedVector2Array:
    var polygon := PackedVector2Array()
    for i in range(points):
        var angle := TAU * float(i) / float(points)
        polygon.append(Vector2(cos(angle), sin(angle)) * radius)
    return polygon

func _ellipse_polygon(radius_x: float, radius_y: float, points: int) -> PackedVector2Array:
    var polygon := PackedVector2Array()
    for i in range(points):
        var angle := TAU * float(i) / float(points)
        polygon.append(Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
    return polygon

func _on_stamina_changed(current: float, maximum: float) -> void:
    stamina_bar.max_value = maximum
    stamina_bar.value = current
    stamina_text.text = "STAMINA  %d / %d" % [roundi(current), roundi(maximum)]

func _on_terrain_changed(terrain_name: String, multiplier: float) -> void:
    terrain_text.text = "Terrain: %s   x%.2f" % [terrain_name.capitalize(), multiplier]

func _on_infinite_stamina_changed(enabled: bool) -> void:
    var state := "ON" if enabled else "OFF"
    debug_text.text = "Infinite stamina: %s" % state

func _on_movement_state_changed(state_name: String, speed: float) -> void:
    movement_text.text = "%s   |   Speed: %.1f" % [state_name, speed]

func _on_skin_changed(index: int, total: int) -> void:
    skin_text.text = "Skin: %d / %d   (F2)" % [index + 1, total]

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color("98b86f"), true)

    # Slightly stronger lighting bands to sell depth and keep the area readable.
    draw_rect(Rect2(0.0, 0.0, MAP_SIZE.x, 180.0), Color(1.0, 1.0, 1.0, 0.03), true)
    draw_rect(Rect2(0.0, 420.0, MAP_SIZE.x, 180.0), Color(0.0, 0.0, 0.0, 0.035), true)

    draw_line(Vector2(40, 245), Vector2(920, 245), Color(1, 1, 1, 0.22), 2.0)
    draw_line(Vector2(40, 395), Vector2(920, 395), Color(1, 1, 1, 0.22), 2.0)

    _draw_zone_label(Vector2(65, 55), "TREE COLLISION")
    _draw_zone_label(Vector2(330, 55), "WALL / CORNER TEST")
    _draw_zone_label(Vector2(90, 255), "BUSHES - 75% SPEED")
    _draw_zone_label(Vector2(620, 255), "ROCKS - 55% SPEED")
    _draw_zone_label(Vector2(70, 415), "MIXED OBSTACLE COURSE")
    _draw_zone_label(Vector2(700, 85), "3/4 FACADE TEST")

    draw_dashed_line(Vector2(370, 322), Vector2(590, 322), Color(1, 1, 1, 0.55), 2.0, 10.0)

func _draw_zone_label(pos: Vector2, text: String) -> void:
    var font := ThemeDB.fallback_font
    draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.08, 0.12, 0.08, 0.82))
