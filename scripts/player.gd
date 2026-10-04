class_name DemoPlayer
extends CharacterBody2D

signal stamina_changed(current: float, maximum: float)
signal terrain_changed(terrain_name: String, multiplier: float)
signal infinite_stamina_changed(enabled: bool)
signal movement_state_changed(state_name: String, speed: float)
signal skin_changed(index: int, total: int)

const SKIN_COUNT := 15
const SKIN_PATH_TEMPLATE := "res://assets/characters/villagers/skin_%02d.png"
const FRAME_SIZE := Vector2(32.0, 64.0)
const WALK_SEQUENCE := [0, 1, 2, 1]

var config: Dictionary = {}

var max_stamina := 100.0
var stamina := 100.0

var walk_speed := 100.0
var run_speed := 170.0
var dash_speed := 340.0
var dash_duration := 0.18
var dash_cost := 25.0
var dash_cooldown := 0.35

var run_cost_per_second := 15.0
var stamina_regen_per_second := 25.0
var stamina_regen_delay := 0.75

var walk_animation_fps := 6.0
var run_animation_fps := 10.0
var dash_animation_fps := 14.0
var sprite_offset_y := -8.0

var infinite_stamina := false
var current_skin := 0

var last_facing := Vector2.DOWN
var dash_direction := Vector2.ZERO
var dash_time_left := 0.0
var dash_cooldown_left := 0.0
var regen_delay_left := 0.0

var current_terrain := "normal"
var terrain_multiplier := 1.0
var terrain_overlaps: Dictionary = {}
var last_reported_state := ""
var last_reported_speed := -1.0

var visual_state := "Idle"
var animation_time := 0.0

var terrain_detector: Area2D
var character_sprite: Sprite2D

func _ready() -> void:
    print("DemoPlayer: initializing")
    terrain_detector = get_node_or_null("TerrainDetector") as Area2D
    character_sprite = get_node_or_null("CharacterSprite") as Sprite2D
    if terrain_detector == null or character_sprite == null:
        if terrain_detector == null:
            push_error("DemoPlayer: missing required node 'TerrainDetector'.")
        if character_sprite == null:
            push_error("DemoPlayer: missing required node 'CharacterSprite'.")
        set_physics_process(false)
        set_process_unhandled_input(false)
        return

    _load_config()
    if not terrain_detector.area_entered.is_connected(_on_terrain_entered):
        terrain_detector.area_entered.connect(_on_terrain_entered)
    if not terrain_detector.area_exited.is_connected(_on_terrain_exited):
        terrain_detector.area_exited.connect(_on_terrain_exited)
    print("DemoPlayer: terrain callbacks connected")

    character_sprite.position.y = sprite_offset_y
    _apply_skin(current_skin)
    _update_sprite_frame()
    queue_redraw()

    stamina_changed.emit(stamina, max_stamina)
    terrain_changed.emit(current_terrain, terrain_multiplier)
    infinite_stamina_changed.emit(infinite_stamina)
    skin_changed.emit(current_skin, SKIN_COUNT)

func _load_config() -> void:
    config = GameConfig.load_data()
    if config.is_empty():
        return

    var player_cfg: Dictionary = config.get("player", {})
    var base_stats: Dictionary = player_cfg.get("base_stats", {})
    var movement: Dictionary = player_cfg.get("movement", {})
    var stamina_cfg: Dictionary = player_cfg.get("stamina", {})
    var visuals_cfg: Dictionary = player_cfg.get("visuals", {})
    var debug_cfg: Dictionary = config.get("debug", {})

    max_stamina = maxf(0.0, float(base_stats.get("max_stamina", max_stamina)))
    stamina = max_stamina

    walk_speed = maxf(0.0, float(movement.get("walk_speed", walk_speed)))
    run_speed = maxf(0.0, float(movement.get("run_speed", run_speed)))
    dash_speed = maxf(0.0, float(movement.get("dash_speed", dash_speed)))
    dash_duration = maxf(0.0, float(movement.get("dash_duration", dash_duration)))
    dash_cost = maxf(0.0, float(movement.get("dash_cost", dash_cost)))
    dash_cooldown = maxf(0.0, float(movement.get("dash_cooldown", dash_cooldown)))

    run_cost_per_second = maxf(0.0, float(stamina_cfg.get("run_cost_per_second", run_cost_per_second)))
    stamina_regen_per_second = maxf(0.0, float(stamina_cfg.get("regen_per_second", stamina_regen_per_second)))
    stamina_regen_delay = maxf(0.0, float(stamina_cfg.get("regen_delay", stamina_regen_delay)))

    current_skin = clampi(int(visuals_cfg.get("default_skin", current_skin)), 0, SKIN_COUNT - 1)
    walk_animation_fps = maxf(0.0, float(visuals_cfg.get("walk_animation_fps", walk_animation_fps)))
    run_animation_fps = maxf(0.0, float(visuals_cfg.get("run_animation_fps", run_animation_fps)))
    dash_animation_fps = maxf(0.0, float(visuals_cfg.get("dash_animation_fps", dash_animation_fps)))
    sprite_offset_y = float(visuals_cfg.get("sprite_offset_y", sprite_offset_y))

    infinite_stamina = bool(debug_cfg.get("infinite_stamina_default", false))

func _physics_process(delta: float) -> void:
    dash_cooldown_left = maxf(0.0, dash_cooldown_left - delta)
    regen_delay_left = maxf(0.0, regen_delay_left - delta)

    if dash_time_left > 0.0:
        _process_dash(delta)
    else:
        _process_normal_movement(delta)

    _process_stamina_regen(delta)
    _update_sprite_animation(delta)

    # Player origin represents the feet, which is what we want for depth sorting.
    z_index = int(round(global_position.y))

func _unhandled_input(event: InputEvent) -> void:
    if not (event is InputEventKey):
        return

    var key_event := event as InputEventKey
    if not key_event.pressed or key_event.echo:
        return

    if key_event.keycode == KEY_F1:
        infinite_stamina = not infinite_stamina
        if infinite_stamina:
            stamina = max_stamina
            stamina_changed.emit(stamina, max_stamina)
        infinite_stamina_changed.emit(infinite_stamina)
        get_viewport().set_input_as_handled()
        return

    if key_event.keycode == KEY_F2:
        _apply_skin((current_skin + 1) % SKIN_COUNT)
        get_viewport().set_input_as_handled()
        return

    var is_alt := key_event.keycode == KEY_ALT or key_event.physical_keycode == KEY_ALT
    var is_left_alt := key_event.location == KEY_LOCATION_LEFT or key_event.location == KEY_LOCATION_UNSPECIFIED
    if is_alt and is_left_alt and not key_event.ctrl_pressed:
        _try_dash()
        get_viewport().set_input_as_handled()

func _process_normal_movement(delta: float) -> void:
    var input_direction := _get_input_direction()
    if input_direction != Vector2.ZERO:
        last_facing = input_direction

    var wants_to_run := Input.is_physical_key_pressed(KEY_SHIFT) and input_direction != Vector2.ZERO
    var can_run := infinite_stamina or stamina > 0.0
    var is_running := wants_to_run and can_run

    var chosen_speed := run_speed if is_running else walk_speed
    var final_speed := chosen_speed * terrain_multiplier
    velocity = input_direction * final_speed

    if is_running and not infinite_stamina:
        _spend_stamina(run_cost_per_second * delta)

    move_and_slide()

    var state := "Idle"
    if input_direction != Vector2.ZERO:
        state = "Run" if is_running else "Walk"

    _set_visual_state(state)
    _report_movement_state(state, velocity.length())

func _process_dash(delta: float) -> void:
    dash_time_left = maxf(0.0, dash_time_left - delta)
    velocity = dash_direction * dash_speed * terrain_multiplier
    move_and_slide()
    _set_visual_state("Dash")
    _report_movement_state("Dash", velocity.length())

    if dash_time_left <= 0.0:
        velocity = Vector2.ZERO

func _try_dash() -> void:
    if dash_time_left > 0.0 or dash_cooldown_left > 0.0:
        return

    if not infinite_stamina and stamina < dash_cost:
        return

    var input_direction := _get_input_direction()
    dash_direction = input_direction if input_direction != Vector2.ZERO else last_facing
    if dash_direction == Vector2.ZERO:
        dash_direction = Vector2.DOWN

    last_facing = dash_direction
    dash_time_left = dash_duration
    dash_cooldown_left = dash_cooldown
    _set_visual_state("Dash")

    if not infinite_stamina:
        _spend_stamina(dash_cost)
    print("DemoPlayer: dash started in direction %s" % dash_direction)

func _apply_skin(index: int) -> void:
    if character_sprite == null:
        push_error("DemoPlayer: cannot apply a skin without 'CharacterSprite'.")
        return
    current_skin = (index + SKIN_COUNT) % SKIN_COUNT
    var path := SKIN_PATH_TEMPLATE % (current_skin + 1)
    var loaded_texture := load(path) as Texture2D
    if loaded_texture == null:
        push_error("Could not load player skin: %s" % path)
        return

    character_sprite.texture = loaded_texture
    _update_sprite_frame()
    skin_changed.emit(current_skin, SKIN_COUNT)

func get_skin_count() -> int:
    return SKIN_COUNT

func _set_visual_state(state_name: String) -> void:
    if state_name == visual_state:
        return
    visual_state = state_name
    animation_time = 0.0
    _update_sprite_frame()

func _update_sprite_animation(delta: float) -> void:
    animation_time += delta
    _update_sprite_frame()

func _update_sprite_frame() -> void:
    if character_sprite == null or character_sprite.texture == null:
        return

    var frame := 1
    match visual_state:
        "Walk":
            frame = WALK_SEQUENCE[int(floor(animation_time * walk_animation_fps)) % WALK_SEQUENCE.size()]
        "Run":
            frame = WALK_SEQUENCE[int(floor(animation_time * run_animation_fps)) % WALK_SEQUENCE.size()]
        "Dash":
            frame = 0 if int(floor(animation_time * dash_animation_fps)) % 2 == 0 else 2
        _:
            frame = 1

    var direction_row := 0
    character_sprite.flip_h = false

    if absf(last_facing.x) > absf(last_facing.y):
        direction_row = 2
        character_sprite.flip_h = last_facing.x < 0.0
    elif last_facing.y < 0.0:
        direction_row = 1
    else:
        direction_row = 0

    character_sprite.region_rect = Rect2(
        Vector2(frame * FRAME_SIZE.x, direction_row * FRAME_SIZE.y),
        FRAME_SIZE
    )

func _spend_stamina(amount: float) -> void:
    stamina = maxf(0.0, stamina - amount)
    regen_delay_left = stamina_regen_delay
    stamina_changed.emit(stamina, max_stamina)

func _process_stamina_regen(delta: float) -> void:
    if infinite_stamina:
        if stamina != max_stamina:
            stamina = max_stamina
            stamina_changed.emit(stamina, max_stamina)
        return

    if regen_delay_left > 0.0 or stamina >= max_stamina:
        return

    stamina = minf(max_stamina, stamina + stamina_regen_per_second * delta)
    stamina_changed.emit(stamina, max_stamina)

func _get_input_direction() -> Vector2:
    var x := float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
    var y := float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
    var direction := Vector2(x, y)
    return direction.normalized() if direction.length_squared() > 0.0 else Vector2.ZERO

func _on_terrain_entered(area: Area2D) -> void:
    if not area.has_meta("terrain_name"):
        return

    terrain_overlaps[area.get_instance_id()] = {
        "name": str(area.get_meta("terrain_name")),
        "multiplier": maxf(0.0, float(area.get_meta("movement_multiplier", 1.0)))
    }
    _recalculate_terrain()

func _on_terrain_exited(area: Area2D) -> void:
    terrain_overlaps.erase(area.get_instance_id())
    _recalculate_terrain()

func _recalculate_terrain() -> void:
    var best_name := "normal"
    var best_multiplier := 1.0

    for entry in terrain_overlaps.values():
        var multiplier := float(entry.get("multiplier", 1.0))
        if multiplier < best_multiplier:
            best_multiplier = multiplier
            best_name = str(entry.get("name", "normal"))

    if best_name != current_terrain or not is_equal_approx(best_multiplier, terrain_multiplier):
        current_terrain = best_name
        terrain_multiplier = best_multiplier
        terrain_changed.emit(current_terrain, terrain_multiplier)

func _report_movement_state(state_name: String, speed: float) -> void:
    if state_name == last_reported_state and is_equal_approx(speed, last_reported_speed):
        return
    last_reported_state = state_name
    last_reported_speed = speed
    movement_state_changed.emit(state_name, speed)

func _ellipse_polygon(radius_x: float, radius_y: float, points: int) -> PackedVector2Array:
    var polygon := PackedVector2Array()
    for i in range(points):
        var angle := TAU * float(i) / float(points)
        polygon.append(Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
    return polygon

func _draw() -> void:
    # Keep a tiny grounding shadow underneath the sprite.
    var shadow := _ellipse_polygon(8.0, 3.5, 20)
    draw_colored_polygon(shadow, Color(0.0, 0.0, 0.0, 0.16), PackedVector2Array(), null)
